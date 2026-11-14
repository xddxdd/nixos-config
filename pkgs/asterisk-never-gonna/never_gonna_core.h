/* SPDX-License-Identifier: GPL-2.0-only
 * This license covers code, not the third-party audio assets.
 */
#ifndef NEVER_GONNA_CORE_H
#define NEVER_GONNA_CORE_H

#include <stddef.h>
#include <stdint.h>
#include <string.h>

enum ng_state {
	NG_NEVER,
	NG_GONNA,
	NG_GIVE,
	NG_LET,
	NG_YOU,
	NG_YOU1,
	NG_YOU2,
	NG_UP,
	NG_DOWN,
	NG_RUN,
	NG_AROUND,
	NG_AND,
	NG_DESERT,
	NG_MAKE,
	NG_CRY,
	NG_SAY,
	NG_GOODBYE,
	NG_TELL,
	NG_ALIE,
	NG_HURT,
	NG_STATE_COUNT
};

struct ng_clip {
	const int16_t *pcm;
	size_t samples;
};

struct ng_cursor {
	enum ng_state state;
	size_t offset;
};

typedef uint32_t (*ng_random_fn)(void *data);

/* SplitMix64: per-call state, with no entropy-device I/O at clip boundaries. */
static inline uint32_t ng_random_u32(void *data)
{
	uint64_t *state = data;
	uint64_t value = (*state += UINT64_C(0x9e3779b97f4a7c15));

	value = (value ^ (value >> 30)) * UINT64_C(0xbf58476d1ce4e5b9);
	value = (value ^ (value >> 27)) * UINT64_C(0x94d049bb133111eb);
	return (uint32_t)((value ^ (value >> 31)) >> 32);
}

/* Reject the short residue classes rather than biasing the six-way branch. */
static inline uint32_t ng_uniform(uint32_t bound, ng_random_fn random, void *data)
{
	uint32_t threshold = (uint32_t)(-bound) % bound;
	uint32_t value;

	do {
		value = random(data);
	} while (value < threshold);
	return value % bound;
}

static inline enum ng_state ng_next(enum ng_state state, ng_random_fn random, void *data)
{
	switch (state) {
	case NG_NEVER:
		return NG_GONNA;
	case NG_GONNA: {
		static const enum ng_state branches[] = {NG_SAY,  NG_RUN,  NG_TELL,
							 NG_MAKE, NG_GIVE, NG_LET};
		return branches[ng_uniform(6, random, data)];
	}
	case NG_GIVE:
	case NG_MAKE:
		return NG_YOU;
	case NG_YOU:
		return ng_uniform(2, random, data) == 0 ? NG_CRY : NG_UP;
	case NG_LET:
		return NG_YOU2;
	case NG_YOU2:
		return NG_DOWN;
	case NG_RUN:
		return NG_AROUND;
	case NG_AROUND:
		return NG_AND;
	case NG_AND:
		return ng_uniform(2, random, data) == 0 ? NG_DESERT : NG_HURT;
	case NG_DESERT:
	case NG_HURT:
		return NG_YOU1;
	case NG_SAY:
		return NG_GOODBYE;
	case NG_TELL:
		return NG_ALIE;
	case NG_ALIE:
		return NG_AND;
	case NG_GOODBYE:
	case NG_DOWN:
	case NG_CRY:
	case NG_UP:
	case NG_YOU1:
		return NG_NEVER;
	case NG_STATE_COUNT:
		break;
	}
	return NG_NEVER;
}

/* Clips are build-validated, nonempty PCM. The cursor may sit exactly at EOF;
 * the next transition is selected only when another sample is requested.
 */
static inline void ng_fill(struct ng_cursor *cursor, const struct ng_clip clips[NG_STATE_COUNT],
			   int16_t *output, size_t samples, ng_random_fn random, void *data)
{
	while (samples) {
		const struct ng_clip *clip = &clips[cursor->state];
		size_t count;

		if (cursor->offset == clip->samples) {
			cursor->state = ng_next(cursor->state, random, data);
			cursor->offset = 0;
			continue;
		}
		count = clip->samples - cursor->offset;
		if (count > samples) {
			count = samples;
		}
		memcpy(output, clip->pcm + cursor->offset, count * sizeof(*output));
		cursor->offset += count;
		output += count;
		samples -= count;
	}
}

#endif
