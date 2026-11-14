# SPDX-License-Identifier: GPL-2.0-only
import io
import struct
import subprocess
import sys
import tempfile
import unittest
import wave
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
import generate_audio  # noqa: E402

EXPECTED_CLIPS = (
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


def wav_bytes(pcm, channels=2, width=2, rate=44100):
    output = io.BytesIO()
    with wave.open(output, "wb") as wav:
        wav.setnchannels(channels)
        wav.setsampwidth(width)
        wav.setframerate(rate)
        wav.writeframes(pcm)
    return output.getvalue()


def riff(body):
    return b"RIFF" + struct.pack("<I", len(body) + 4) + b"WAVE" + body


class AudioTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.path = Path(self.directory.name) / "clip.wav"
        self.valid = wav_bytes(struct.pack("<hhhh", 10, 20, -10, -21))

    def read(self, raw):
        self.path.write_bytes(raw)
        return generate_audio.read_mono(self.path)

    def test_original_state_asset_mapping_and_only_used_assets(self):
        self.assertEqual(generate_audio.CLIPS, EXPECTED_CLIPS)
        self.assertEqual(len({name for state, name in generate_audio.CLIPS}), 20)

    def test_rust_stereo_average_extremes_and_negative_odd_sums(self):
        frames = [
            (-32768, -32768),
            (32767, 32767),
            (-32768, 32767),
            (-1, 0),
            (-1, -2),
            (-3, 0),
            (0, 1),
            (1, 2),
            (-32768, 0),
        ]
        pcm = b"".join(struct.pack("<hh", *frame) for frame in frames)
        self.assertEqual(
            self.read(wav_bytes(pcm)), [-32768, 32767, 0, 0, -1, -1, 0, 1, -16384]
        )

    def test_unknown_odd_sized_chunks_are_padded_and_skipped(self):
        raw = riff(b"JUNK" + struct.pack("<I", 3) + b"abc\x00" + self.valid[12:])
        self.assertEqual(self.read(raw), [15, -15])

    def test_wrong_channels_width_and_rate_are_rejected(self):
        for channels, width, rate in (
            (1, 2, 44100),
            (2, 1, 44100),
            (2, 3, 44100),
            (2, 2, 48000),
            (2, 2, 22050),
        ):
            with self.subTest(channels=channels, width=width, rate=rate):
                with self.assertRaises(ValueError):
                    self.read(
                        wav_bytes(bytes(channels * width * 2), channels, width, rate)
                    )

    def test_bad_riff_signatures_sizes_and_truncation_are_rejected(self):
        for raw in (
            b"",
            b"RIFF",
            b"RIFX" + self.valid[4:],
            self.valid[:8] + b"NOPE" + self.valid[12:],
            self.valid[:-1],
            self.valid + b"extra",
            riff(self.valid[12:] + b"JUNK\x08\x00\x00\x00x"),
            riff(self.valid[12:] + b"tail"),
        ):
            with self.subTest(raw=raw[:16], size=len(raw)):
                with self.assertRaises(ValueError):
                    self.read(raw)

    def test_non_pcm_and_inconsistent_format_fields_are_rejected(self):
        for offset, code, value in (
            (20, "H", 3),
            (28, "I", 1),
            (32, "H", 2),
            (34, "H", 8),
        ):
            raw = bytearray(self.valid)
            struct.pack_into("<" + code, raw, offset, value)
            with self.subTest(offset=offset):
                with self.assertRaises(ValueError):
                    self.read(raw)

    def test_empty_and_partial_stereo_frames_are_rejected(self):
        fmt_chunk = self.valid[12:36]
        for pcm in (b"", b"\x00", b"\x00\x00", b"\x00" * 6):
            body = fmt_chunk + b"data" + struct.pack("<I", len(pcm)) + pcm
            if len(pcm) & 1:
                body += b"\x00"
            with self.subTest(length=len(pcm)):
                with self.assertRaises(ValueError):
                    self.read(riff(body))

    def test_missing_duplicate_and_truncated_required_chunks_are_rejected(self):
        fmt_chunk, data_chunk = self.valid[12:36], self.valid[36:]
        bodies = (
            fmt_chunk,
            data_chunk,
            fmt_chunk + fmt_chunk + data_chunk,
            fmt_chunk + data_chunk + data_chunk,
            b"fmt " + struct.pack("<I", 2) + b"\x01\x00" + data_chunk,
            fmt_chunk + b"data" + struct.pack("<I", 100) + b"\x00\x00\x00\x00",
            b"JUNK" + struct.pack("<I", 1) + b"x",
        )
        for body in bodies:
            with self.subTest(body=body[:16], size=len(body)):
                with self.assertRaises(ValueError):
                    self.read(riff(body))

    def make_assets(self):
        music = Path(self.directory.name) / "music"
        music.mkdir()
        for index, (state, name) in enumerate(EXPECTED_CLIPS):
            (music / f"{name}.wav").write_bytes(
                wav_bytes(struct.pack("<hh", index, index))
            )
        return music

    def test_generation_is_deterministic_and_uses_static_read_only_arrays(self):
        music = self.make_assets()
        output = Path(self.directory.name) / "never_gonna_audio.h"
        generate_audio.generate(music, output)
        first = output.read_bytes()
        generate_audio.generate(music, output)
        self.assertEqual(output.read_bytes(), first)
        text = first.decode("ascii")
        self.assertIn("static const struct ng_clip ng_clips[NG_STATE_COUNT]", text)
        self.assertEqual(text.count("static const int16_t ng_pcm_"), 20)
        for index, (state, name) in enumerate(EXPECTED_CLIPS):
            self.assertIn(
                f"static const int16_t ng_pcm_{name}[] = {{\n\t{index},\n}};", text
            )
            self.assertIn(f"[NG_{state}] = {{ ng_pcm_{name},", text)
        self.assertNotIn("ng_pcm_and2", text)
        self.assertIn("no audio license is granted", text)

    def test_missing_input_does_not_create_or_overwrite_output(self):
        music = self.make_assets()
        (music / "hurt.wav").unlink()
        output = Path(self.directory.name) / "never_gonna_audio.h"
        with self.assertRaises(FileNotFoundError):
            generate_audio.generate(music, output)
        self.assertFalse(output.exists())
        output.write_text("keep", encoding="ascii")
        with self.assertRaises(FileNotFoundError):
            generate_audio.generate(music, output)
        self.assertEqual(output.read_text(encoding="ascii"), "keep")

    def test_invalid_last_input_does_not_overwrite_output(self):
        music = self.make_assets()
        (music / "hurt.wav").write_bytes(wav_bytes(b"", rate=48000))
        output = Path(self.directory.name) / "never_gonna_audio.h"
        output.write_text("keep", encoding="ascii")
        with self.assertRaises(ValueError):
            generate_audio.generate(music, output)
        self.assertEqual(output.read_text(encoding="ascii"), "keep")

    def test_cli_invalid_input_fails_before_creating_output(self):
        music = self.make_assets()
        (music / "you1.wav").write_bytes(b"invalid")
        output = Path(self.directory.name) / "never_gonna_audio.h"
        result = subprocess.run(
            [
                sys.executable,
                str(ROOT / "tools/generate_audio.py"),
                str(music),
                str(output),
            ],
            capture_output=True,
            text=True,
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("you1.wav", result.stderr)
        self.assertFalse(output.exists())


if __name__ == "__main__":
    unittest.main()
