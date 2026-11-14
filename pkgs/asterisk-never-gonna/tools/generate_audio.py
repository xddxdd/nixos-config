#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-2.0-only
# The generated PCM and source recordings are not licensed by this code notice.

import argparse
import io
import struct
import wave
from pathlib import Path

CLIPS = (
    ("NEVER", "never"),
    ("GONNA", "gonna"),
    ("GIVE", "give"),
    ("LET", "let"),
    ("YOU", "you1"),
    ("YOU1", "you2"),
    ("YOU2", "you3"),
    ("UP", "up"),
    ("DOWN", "down"),
    ("RUN", "run"),
    ("AROUND", "around"),
    ("AND", "and"),
    ("DESERT", "desert"),
    ("MAKE", "make"),
    ("CRY", "cry"),
    ("SAY", "say"),
    ("GOODBYE", "goodbye"),
    ("TELL", "tell"),
    ("ALIE", "alie"),
    ("HURT", "hurt"),
)


def read_mono(path):
    raw = Path(path).read_bytes()
    if (
        len(raw) < 12
        or raw[:4] != b"RIFF"
        or raw[8:12] != b"WAVE"
        or struct.unpack_from("<I", raw, 4)[0] + 8 != len(raw)
    ):
        raise ValueError(f"{path}: invalid or truncated RIFF/WAVE")

    position = 12
    chunks = {}
    while position < len(raw):
        if position + 8 > len(raw):
            raise ValueError(f"{path}: truncated chunk header")
        name, size = struct.unpack_from("<4sI", raw, position)
        start = position + 8
        position = start + size + (size & 1)
        if position > len(raw):
            raise ValueError(f"{path}: truncated chunk or missing padding")
        if name in (b"fmt ", b"data"):
            if name in chunks:
                raise ValueError(f"{path}: duplicate {name!r} chunk")
            chunks[name] = raw[start : start + size]

    fmt = chunks.get(b"fmt ", b"")
    if len(fmt) < 16 or struct.unpack_from("<HHIIHH", fmt) != (
        1,
        2,
        44100,
        176400,
        4,
        16,
    ):
        raise ValueError(f"{path}: expected PCM16 stereo 44100 Hz with block align 4")
    pcm = chunks.get(b"data", b"")
    if not pcm or len(pcm) % 4:
        raise ValueError(f"{path}: empty or incomplete stereo PCM frames")

    with wave.open(io.BytesIO(raw), "rb") as wav:
        if wav.getcomptype() != "NONE" or wav.getnframes() * 4 != len(pcm):
            raise ValueError(f"{path}: inconsistent WAV frame count")
        if wav.readframes(wav.getnframes() + 1) != pcm:
            raise ValueError(f"{path}: inconsistent WAV data")

    mono = []
    for left, right in struct.iter_unpack("<hh", pcm):
        total = left + right
        # Rust's signed integer division truncates toward zero, not -infinity.
        mono.append(total // 2 if total >= 0 else -((-total) // 2))
    return mono


def generate(music_dir, output):
    # Validate every input before opening the output, including missing assets.
    clips = [
        (state, name, read_mono(Path(music_dir) / f"{name}.wav"))
        for state, name in CLIPS
    ]
    with Path(output).open("w", encoding="ascii", newline="\n") as header:
        header.write(
            "/* Generated PCM from third-party recordings; no audio license is granted. */\n"
            "#ifndef NEVER_GONNA_AUDIO_H\n#define NEVER_GONNA_AUDIO_H\n\n"
            '#include "never_gonna_core.h"\n\n'
        )
        for state, name, pcm in clips:
            header.write(f"/* {state} => {name}.wav */\n")
            header.write(f"static const int16_t ng_pcm_{name}[] = {{\n")
            for start in range(0, len(pcm), 16):
                header.write(
                    "\t" + ", ".join(map(str, pcm[start : start + 16])) + ",\n"
                )
            header.write("};\n\n")
        header.write("static const struct ng_clip ng_clips[NG_STATE_COUNT] = {\n")
        for state, name, pcm in clips:
            header.write(
                f"\t[NG_{state}] = {{ ng_pcm_{name}, "
                f"sizeof(ng_pcm_{name}) / sizeof(ng_pcm_{name}[0]) }},\n"
            )
        header.write("};\n\n#endif\n")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Embed PCM16 stereo 44100 Hz WAVs as mono C arrays"
    )
    parser.add_argument("music_dir", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    try:
        generate(args.music_dir, args.output)
    except (OSError, ValueError, wave.Error, EOFError) as error:
        parser.exit(1, f"{error}\n")
