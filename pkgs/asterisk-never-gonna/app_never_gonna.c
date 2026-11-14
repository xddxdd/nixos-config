/* SPDX-License-Identifier: GPL-2.0-only
 * This license covers the module code, not the third-party song or recordings.
 */

/*! \file
 * \brief Sample-continuous Markov song generator.
 */

/*** MODULEINFO
	<support_level>extended</support_level>
 ***/

#include "asterisk.h"

#include "asterisk/astobj2.h"
#include "asterisk/channel.h"
#include "asterisk/format.h"
#include "asterisk/format_cache.h"
#include "asterisk/frame.h"
#include "asterisk/lock.h"
#include "asterisk/module.h"
#include "asterisk/pbx.h"
#include "asterisk/timing.h"
#include "asterisk/utils.h"

#include "never_gonna_audio.h"
#include "never_gonna_core.h"

#define NG_FRAME_SAMPLES 882

static const char app[] = "NeverGonna";
static const char synopsis[] = "Play a sample-continuous Markov chain of song fragments.";
static const char description[] =
    "NeverGonna()\n"
    "Answers the channel and plays indefinitely until hangup or error.\n"
    "Audio is generated as 44100 Hz signed linear mono. Clip boundaries\n"
    "do not insert silence, discard samples, or restart the generator.\n"
    "Channel codec translation and the original recording can still\n"
    "affect what the caller hears. No arguments are accepted.\n";

struct never_gonna_call {
	struct ng_cursor cursor;
	uint64_t random_state;
	struct ast_format *old_write_format;
	int16_t buffer[AST_FRIENDLY_OFFSET / sizeof(int16_t) + NG_FRAME_SAMPLES];
};

static void *never_gonna_alloc(struct ast_channel *chan, void *params)
{
	struct never_gonna_call *call = ast_calloc(1, sizeof(*call));

	(void)params;
	if (!call) {
		return NULL;
	}
	call->cursor.state = NG_NEVER;
	/* ast_random() may read /dev/urandom. Seed once, before any playback. */
	call->random_state = ((uint64_t)(ast_random() & 0x7fffffff) << 33) |
			     ((uint64_t)(ast_random() & 0x7fffffff) << 2) |
			     (uint64_t)(ast_random() & 3);
	call->old_write_format = ao2_bump(ast_channel_writeformat(chan));
	if (ast_set_write_format(chan, ast_format_slin44)) {
		ast_log(LOG_WARNING, "Cannot set 44100 Hz signed linear on '%s'\n",
			ast_channel_name(chan));
		if (ast_set_write_format(chan, call->old_write_format)) {
			ast_log(LOG_WARNING, "Cannot restore write format on '%s'\n",
				ast_channel_name(chan));
		}
		ao2_cleanup(call->old_write_format);
		ast_free(call);
		return NULL;
	}
	return call;
}

static void never_gonna_release(struct ast_channel *chan, void *data)
{
	struct never_gonna_call *call = data;

	if (ast_set_write_format(chan, call->old_write_format)) {
		ast_log(LOG_WARNING, "Cannot restore write format on '%s'\n",
			ast_channel_name(chan));
	}
	ao2_cleanup(call->old_write_format);
	ast_free(call);
}

static int never_gonna_generate(struct ast_channel *chan, void *data, int len, int samples)
{
	struct never_gonna_call *call = data;
	int16_t *pcm = call->buffer + AST_FRIENDLY_OFFSET / sizeof(int16_t);
	struct ast_frame frame = {
	    .frametype = AST_FRAME_VOICE,
	    .subclass.format = ast_format_slin44,
	    .data.ptr = pcm,
	    .offset = AST_FRIENDLY_OFFSET,
	    .src = "NeverGonna",
	};
	int format_ok;

	(void)len;
	/* channel.c derives samples from the write format. Do not silently play at
	 * another rate if something outside this application changes that format.
	 */
	ast_channel_lock(chan);
	format_ok = ast_format_cmp(ast_channel_writeformat(chan), ast_format_slin44) ==
		    AST_FORMAT_CMP_EQUAL;
	ast_channel_unlock(chan);
	if (!format_ok || samples < 0) {
		ast_log(LOG_WARNING, "NeverGonna generator format/request changed on '%s'\n",
			ast_channel_name(chan));
		return -1;
	}

	/* Never clamp a request: large requests are split into bounded writes,
	 * with one uninterrupted cursor and complete frames across clip edges.
	 */
	while (samples > 0) {
		int count = samples > NG_FRAME_SAMPLES ? NG_FRAME_SAMPLES : samples;

		if (ast_check_hangup(chan)) {
			return -1;
		}
		ng_fill(&call->cursor, ng_clips, pcm, (size_t)count, ng_random_u32,
			&call->random_state);
		frame.samples = count;
		frame.datalen = count * sizeof(*pcm);
		if (ast_write(chan, &frame) < 0) {
			ast_log(LOG_WARNING, "NeverGonna write failed on '%s'\n",
				ast_channel_name(chan));
			return -1;
		}
		samples -= count;
	}
	return 0;
}

static struct ast_generator never_gonna_generator = {
    .alloc = never_gonna_alloc,
    .release = never_gonna_release,
    .generate = never_gonna_generate,
};

static int never_gonna_exec(struct ast_channel *chan, const char *data)
{
	int wait_result;

	if (!ast_strlen_zero(data)) {
		ast_log(LOG_WARNING, "NeverGonna takes no arguments\n");
		return -1;
	}
	if (ast_channel_state(chan) != AST_STATE_UP && ast_answer(chan)) {
		return -1;
	}

	ast_channel_lock(chan);
	/* Do not replace someone else's generator or disturb its write format. */
	if (ast_channel_generator(chan)) {
		ast_channel_unlock(chan);
		ast_log(LOG_WARNING, "A generator is already active on '%s'\n",
			ast_channel_name(chan));
		return -1;
	}
	if (ast_activate_generator(chan, &never_gonna_generator, NULL)) {
		ast_channel_unlock(chan);
		return -1;
	}
	/* Asterisk 22 ignores timer-start errors in ast_activate_generator().
	 * Check the 50 Hz clock explicitly instead of falling back to incoming
	 * voice-frame pacing, which stops under caller silence suppression.
	 */
	if (!ast_channel_timer(chan) || !ast_channel_timingfunc(chan) ||
	    ast_timer_set_rate(ast_channel_timer(chan), 50)) {
		ast_deactivate_generator(chan);
		ast_channel_unlock(chan);
		ast_log(LOG_WARNING, "NeverGonna requires a working 50 Hz Asterisk timer\n");
		return -1;
	}
	ast_channel_unlock(chan);

	for (;;) {
		struct ast_frame *frame;
		int active;

		ast_channel_lock(chan);
		active = ast_channel_generator(chan) == &never_gonna_generator;
		ast_channel_unlock(chan);
		if (!active || (wait_result = ast_waitfor(chan, 1000)) < 0) {
			break;
		}
		if (!wait_result) {
			continue;
		}
		frame = ast_read(chan);
		if (!frame) {
			break;
		}
		ast_frfree(frame);
	}

	/* Asterisk invokes generate/release in the channel thread. The executor
	 * never dereferences generator-owned data, and tears down before pbx_exec
	 * drops its module-user reference. A write error may already release it.
	 */
	ast_channel_lock(chan);
	if (ast_channel_generator(chan) == &never_gonna_generator) {
		ast_deactivate_generator(chan);
	}
	ast_channel_unlock(chan);

	return -1;
}

static int unload_module(void)
{
	/* pbx_exec pins this module through executor cleanup. Forced unload
	 * bypasses that core lifetime guard and must not be used during calls.
	 */
	return ast_unregister_application(app);
}

static int load_module(void)
{
	return ast_register_application(app, never_gonna_exec, synopsis, description);
}

AST_MODULE_INFO_STANDARD_EXTENDED(ASTERISK_GPL_KEY, "Sample-continuous Markov song player");
