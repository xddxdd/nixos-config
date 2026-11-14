# SPDX-License-Identifier: GPL-2.0-only
import os
import shlex
import struct
import subprocess
import sys
import tempfile
import unittest
import wave
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
# State order and asset names from State::wav_data(), not the generator's table.
ORIGINAL_FILES = (
    "never",
    "gonna",
    "give",
    "let",
    "you1",
    "you2",
    "you3",
    "up",
    "down",
    "run",
    "around",
    "and",
    "desert",
    "make",
    "cry",
    "say",
    "goodbye",
    "tell",
    "alie",
    "hurt",
)


class CoreTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        music_dir = os.environ.get("MUSIC_DIR")
        if not music_dir:
            raise RuntimeError(
                "MUSIC_DIR must point to the externally fetched WAV asset directory"
            )
        cls.music_dir = Path(music_dir).resolve()
        if not cls.music_dir.is_dir():
            raise RuntimeError(f"MUSIC_DIR is not a directory: {cls.music_dir}")
        cls.directory = tempfile.TemporaryDirectory()
        cls.addClassCleanup(cls.directory.cleanup)
        directory = Path(cls.directory.name)
        # Exercise the build's generated header, or generate one for local tests.
        header = Path.cwd() / "never_gonna_audio.h"
        if not header.exists():
            header = directory / "never_gonna_audio.h"
            subprocess.run(
                [
                    sys.executable,
                    str(ROOT / "tools/generate_audio.py"),
                    str(cls.music_dir),
                    str(header),
                ],
                check=True,
            )
        cls.harness = directory / "core_harness"
        subprocess.run(
            shlex.split(os.environ.get("CC", "cc"))
            + shlex.split(os.environ.get("CFLAGS", ""))
            + [
                "-std=c11",
                "-O2",
                "-Wall",
                "-Wextra",
                "-Werror",
                "-pedantic",
                "-UNDEBUG",
                "-I",
                str(header.parent),
                "-I",
                str(ROOT),
                str(ROOT / "tests/core_harness.c"),
                "-o",
                str(cls.harness),
            ],
            check=True,
        )

    def test_original_transition_order_and_all_27_edges(self):
        subprocess.run([str(self.harness), "transitions"], check=True)

    def test_exact_pcm_at_every_interior_boundary_on_every_edge(self):
        subprocess.run([str(self.harness), "edges"], check=True)

    def test_request_sizes_exact_eof_and_multiple_boundaries(self):
        subprocess.run([str(self.harness), "requests"], check=True)

    def test_interleaved_calls_have_independent_cursors_and_random_state(self):
        subprocess.run([str(self.harness), "independent"], check=True)

    def test_random_vectors_and_unbiased_rejection(self):
        subprocess.run([str(self.harness), "random"], check=True)

    def test_embedded_pcm_matches_original_rust_mapping_and_conversion(self):
        expected = bytearray()
        for name in ORIGINAL_FILES:
            with wave.open(str(self.music_dir / f"{name}.wav"), "rb") as wav:
                self.assertEqual(
                    (wav.getnchannels(), wav.getsampwidth(), wav.getframerate()),
                    (2, 2, 44100),
                )
                raw = wav.readframes(wav.getnframes())
            for left, right in struct.iter_unpack("<hh", raw):
                # int(float) truncates toward zero, independently of the
                # generator's sign-aware integer arithmetic (sums fit exactly).
                expected.extend(struct.pack("<h", int((left + right) / 2)))
        result = subprocess.run(
            [str(self.harness), "dump"], check=True, capture_output=True
        )
        self.assertEqual(result.stdout, bytes(expected))


if __name__ == "__main__":
    unittest.main()
