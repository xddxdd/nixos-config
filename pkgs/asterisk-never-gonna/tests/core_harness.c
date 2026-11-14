/* SPDX-License-Identifier: GPL-2.0-only */
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "never_gonna_audio.h"
#include "never_gonna_core.h"

/* Independent expectations transcribed from the original Rust match arms,
 * including their branch order. The stitcher/PRNG under test are not copied.
 */
static const struct {
	unsigned int count;
	enum ng_state next[6];
} graph[NG_STATE_COUNT] = {
    [NG_NEVER] = {1, {NG_GONNA}},
    [NG_GONNA] = {6, {NG_SAY, NG_RUN, NG_TELL, NG_MAKE, NG_GIVE, NG_LET}},
    [NG_GIVE] = {1, {NG_YOU}},
    [NG_LET] = {1, {NG_YOU2}},
    [NG_YOU] = {2, {NG_CRY, NG_UP}},
    [NG_YOU1] = {1, {NG_NEVER}},
    [NG_YOU2] = {1, {NG_DOWN}},
    [NG_UP] = {1, {NG_NEVER}},
    [NG_DOWN] = {1, {NG_NEVER}},
    [NG_RUN] = {1, {NG_AROUND}},
    [NG_AROUND] = {1, {NG_AND}},
    [NG_AND] = {2, {NG_DESERT, NG_HURT}},
    [NG_DESERT] = {1, {NG_YOU1}},
    [NG_MAKE] = {1, {NG_YOU}},
    [NG_CRY] = {1, {NG_NEVER}},
    [NG_SAY] = {1, {NG_GOODBYE}},
    [NG_GOODBYE] = {1, {NG_NEVER}},
    [NG_TELL] = {1, {NG_ALIE}},
    [NG_ALIE] = {1, {NG_AND}},
    [NG_HURT] = {1, {NG_YOU1}},
};

struct choice {
	uint32_t value;
	size_t calls;
	int allowed;
};

static uint32_t choose(void *data)
{
	struct choice *choice = data;

	assert(choice->allowed);
	++choice->calls;
	return choice->value;
}

static void transitions(void)
{
	unsigned int state, branch, edges = 0;

	assert(NG_NEVER == 0);
	assert(NG_STATE_COUNT == 20);
	for (state = 0; state < NG_STATE_COUNT; ++state) {
		assert(ng_clips[state].pcm && ng_clips[state].samples);
		for (branch = 0; branch < graph[state].count; ++branch) {
			struct choice choice = {6 + branch, 0, graph[state].count > 1};

			assert(ng_next((enum ng_state)state, choose, &choice) ==
			       graph[state].next[branch]);
			assert(choice.calls == (size_t)choice.allowed);
			++edges;
		}
	}
	assert(edges == 27);
}

static void edges(void)
{
	static const size_t sizes[] = {2, 3, 7, 160, 441, 882, 883, 1764, 4096};
	int16_t actual[4096], expected[4096];
	unsigned int state, branch;
	size_t size_index;

	for (state = 0; state < NG_STATE_COUNT; ++state) {
		const struct ng_clip *source = &ng_clips[state];

		for (branch = 0; branch < graph[state].count; ++branch) {
			enum ng_state next = graph[state].next[branch];
			const struct ng_clip *target = &ng_clips[next];

			for (size_index = 0; size_index < sizeof(sizes) / sizeof(sizes[0]);
			     ++size_index) {
				size_t count = sizes[size_index], tail;

				/* Every possible interior boundary position at these sizes. */
				assert(source->samples >= count && target->samples >= count);
				for (tail = 1; tail < count; ++tail) {
					struct ng_cursor cursor = {(enum ng_state)state,
								   source->samples - tail};
					struct choice choice = {6 + branch, 0,
								graph[state].count > 1};

					memset(actual, 0xa5, sizeof(actual));
					memcpy(expected, source->pcm + source->samples - tail,
					       tail * sizeof(*expected));
					memcpy(expected + tail, target->pcm,
					       (count - tail) * sizeof(*expected));
					ng_fill(&cursor, ng_clips, actual, count, choose, &choice);
					if (memcmp(actual, expected, count * sizeof(*actual))) {
						fprintf(stderr,
							"PCM mismatch: state=%u branch=%u "
							"request=%zu tail=%zu\n",
							state, branch, count, tail);
						abort();
					}
					assert(cursor.state == next &&
					       cursor.offset == count - tail);
					assert(choice.calls == (size_t)choice.allowed);
				}
			}
		}
	}
}

static void requests(void)
{
	static const size_t sizes[] = {1, 2, 3, 159, 160, 441, 882, 883, 10007};
	const size_t total = 44100 * 30;
	int16_t *expected = malloc(total * sizeof(*expected));
	int16_t *actual = malloc(total * sizeof(*actual));
	struct ng_cursor reference = {NG_NEVER, 0};
	uint64_t reference_random = UINT64_C(0x123456789abcdef0);
	size_t index;

	assert(expected && actual);
	ng_fill(&reference, ng_clips, expected, total, ng_random_u32, &reference_random);
	for (index = 0; index < sizeof(sizes) / sizeof(sizes[0]); ++index) {
		struct ng_cursor cursor = {NG_NEVER, 0};
		uint64_t random = UINT64_C(0x123456789abcdef0);
		size_t offset = 0;

		ng_fill(&cursor, ng_clips, NULL, 0, ng_random_u32, &random);
		assert(cursor.state == NG_NEVER && cursor.offset == 0);
		assert(random == UINT64_C(0x123456789abcdef0));
		while (offset < total) {
			size_t count =
			    sizes[index] < total - offset ? sizes[index] : total - offset;

			ng_fill(&cursor, ng_clips, actual + offset, count, ng_random_u32, &random);
			offset += count;
		}
		assert(!memcmp(expected, actual, total * sizeof(*actual)));
		assert(cursor.state == reference.state && cursor.offset == reference.offset);
		assert(random == reference_random);
	}
	/* An exact EOF must not choose a branch until the next nonempty request. */
	{
		struct ng_cursor cursor = {NG_GONNA, ng_clips[NG_GONNA].samples - 1};
		struct choice choice = {10, 0, 1};
		int16_t pcm;

		ng_fill(&cursor, ng_clips, &pcm, 1, choose, &choice);
		assert(pcm == ng_clips[NG_GONNA].pcm[ng_clips[NG_GONNA].samples - 1]);
		assert(cursor.state == NG_GONNA && cursor.offset == ng_clips[NG_GONNA].samples);
		assert(choice.calls == 0);
		ng_fill(&cursor, ng_clips, NULL, 0, choose, &choice);
		assert(choice.calls == 0);
		ng_fill(&cursor, ng_clips, &pcm, 1, choose, &choice);
		assert(cursor.state == NG_GIVE && cursor.offset == 1);
		assert(pcm == ng_clips[NG_GIVE].pcm[0] && choice.calls == 1);
	}
	/* A single request traverses multiple clips without returning early. */
	{
		const int16_t a[] = {-1}, b[] = {2, 3}, c[] = {-4}, d[] = {5};
		const int16_t expected_small[] = {-1, 2, 3, -4, 5, -1, 2, 3, -4, 5, -1};
		struct ng_clip clips[NG_STATE_COUNT] = {
		    [NG_NEVER] = {a, 1},
		    [NG_GONNA] = {b, 2},
		    [NG_SAY] = {c, 1},
		    [NG_GOODBYE] = {d, 1},
		};
		struct ng_cursor cursor = {NG_NEVER, 0};
		struct choice choice = {6, 0, 1};
		int16_t output[11];

		ng_fill(&cursor, clips, output, 11, choose, &choice);
		assert(!memcmp(output, expected_small, sizeof(output)));
		assert(cursor.state == NG_NEVER && cursor.offset == 1 && choice.calls == 2);
	}
	free(actual);
	free(expected);
}

static void independent(void)
{
	const size_t total = 44100 * 10;
	int16_t *expected[2], *actual[2];
	struct ng_cursor cursor[2] = {{NG_NEVER, 0}, {NG_NEVER, 0}};
	struct ng_cursor reference[2] = {{NG_NEVER, 0}, {NG_NEVER, 0}};
	uint64_t random[2] = {1, 2}, reference_random[2] = {1, 2};
	size_t offsets[2] = {0, 0}, step = 0;
	unsigned int i;

	for (i = 0; i < 2; ++i) {
		expected[i] = malloc(total * sizeof(int16_t));
		actual[i] = malloc(total * sizeof(int16_t));
		assert(expected[i] && actual[i]);
		ng_fill(&reference[i], ng_clips, expected[i], total, ng_random_u32,
			&reference_random[i]);
	}
	while (offsets[0] < total || offsets[1] < total) {
		size_t count;

		i = (unsigned int)(step++ % 2);
		count = 1 + step * 127 % 4096;
		if (count > total - offsets[i]) {
			count = total - offsets[i];
		}
		ng_fill(&cursor[i], ng_clips, actual[i] + offsets[i], count, ng_random_u32,
			&random[i]);
		offsets[i] += count;
	}
	for (i = 0; i < 2; ++i) {
		assert(!memcmp(expected[i], actual[i], total * sizeof(int16_t)));
		assert(cursor[i].state == reference[i].state &&
		       cursor[i].offset == reference[i].offset);
		assert(random[i] == reference_random[i]);
		free(actual[i]);
		free(expected[i]);
	}
}

struct sequence {
	const uint32_t *values;
	size_t count, offset;
};

static uint32_t sequence_next(void *data)
{
	struct sequence *sequence = data;

	assert(sequence->offset < sequence->count);
	return sequence->values[sequence->offset++];
}

static void random_choices(void)
{
	static const uint32_t values[] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, UINT32_MAX};
	static const uint32_t binary[] = {0, 1, 2, 3, UINT32_MAX};
	static const uint32_t vectors[] = {UINT32_C(0xe220a839), UINT32_C(0x6e789e6a),
					   UINT32_C(0x06c45d18)};
	struct sequence sequence = {values, sizeof(values) / sizeof(values[0]), 0};
	uint64_t state = 0;
	size_t i;

	assert(ng_uniform(6, sequence_next, &sequence) == 4 && sequence.offset == 5);
	for (i = 5; i < sequence.count; ++i) {
		assert(ng_uniform(6, sequence_next, &sequence) == values[i] % 6);
		assert(sequence.offset == i + 1);
	}
	assert(((UINT64_C(1) << 32) - 4) % 6 == 0);
	sequence.values = binary;
	sequence.count = sizeof(binary) / sizeof(binary[0]);
	sequence.offset = 0;
	for (i = 0; i < sequence.count; ++i) {
		assert(ng_uniform(2, sequence_next, &sequence) == binary[i] % 2);
		assert(sequence.offset == i + 1);
	}
	for (i = 0; i < sizeof(vectors) / sizeof(vectors[0]); ++i) {
		assert(ng_random_u32(&state) == vectors[i]);
	}
}

static void dump(void)
{
	unsigned int state;

	for (state = 0; state < NG_STATE_COUNT; ++state) {
		size_t sample;

		for (sample = 0; sample < ng_clips[state].samples; ++sample) {
			uint16_t value = (uint16_t)ng_clips[state].pcm[sample];

			assert(putchar(value & 255) != EOF);
			assert(putchar(value >> 8) != EOF);
		}
	}
	assert(!fflush(stdout));
}

int main(int argc, char **argv)
{
	assert(argc == 2);
	if (!strcmp(argv[1], "transitions")) {
		transitions();
	} else if (!strcmp(argv[1], "edges")) {
		edges();
	} else if (!strcmp(argv[1], "requests")) {
		requests();
	} else if (!strcmp(argv[1], "independent")) {
		independent();
	} else if (!strcmp(argv[1], "random")) {
		random_choices();
	} else if (!strcmp(argv[1], "dump")) {
		dump();
	} else {
		return 2;
	}
	return 0;
}
