import concurrent.futures
import importlib.util
import os
from pathlib import Path
import pwd
import grp
import shutil
import subprocess
import tempfile
import unittest

spec = importlib.util.spec_from_file_location("generate", Path(__file__).with_name("generate.py"))
generator = importlib.util.module_from_spec(spec)
spec.loader.exec_module(generator)


class SecretsTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.shell = shutil.which("bash")

    def secret(self, path="value", command="printf generated", **extra):
        return dict(path=str(self.root / path), command=command, owner=pwd.getpwuid(os.getuid()).pw_name, group=grp.getgrgid(os.getgid()).gr_name, mode="0600", **extra)

    def test_create_and_preserve_value(self):
        secret = self.secret(command="printf invoked >> count; printf generated")
        generator.generate(secret, self.shell)
        target = self.root / "value"
        first_inode = target.stat().st_ino
        secret["command"] = "exit 99"
        generator.generate(secret, self.shell)
        self.assertEqual(target.read_text(), "generated")
        self.assertEqual(target.stat().st_ino, first_inode)
        self.assertEqual(target.stat().st_mode & 0o777, 0o600)

    def test_empty_existing_file_is_not_regenerated(self):
        (self.root / "value").touch()
        generator.generate(self.secret(command="exit 99"), self.shell)
        self.assertEqual((self.root / "value").read_bytes(), b"")

    def test_mode_update_without_generation(self):
        secret = self.secret()
        generator.generate(secret, self.shell)
        secret.update(mode="0640", command="exit 99")
        generator.generate(secret, self.shell)
        self.assertEqual((self.root / "value").stat().st_mode & 0o777, 0o640)
        self.assertEqual((self.root / "value").read_text(), "generated")

    def test_failure_leaves_no_partial_file_or_output(self):
        secret = self.secret(command="printf do-not-log; printf do-not-log >&2; exit 12")
        with self.assertRaisesRegex(RuntimeError, "exit 12"):
            generator.generate(secret, self.shell)
        self.assertEqual(list(self.root.iterdir()), [])

    def test_empty_output_fails(self):
        with self.assertRaisesRegex(RuntimeError, "empty"):
            generator.generate(self.secret(command="true"), self.shell)
        self.assertEqual(list(self.root.iterdir()), [])

    def test_final_symlink_is_rejected_without_modification(self):
        victim = self.root / "victim"
        victim.write_text("preserved")
        victim.chmod(0o644)
        (self.root / "value").symlink_to(victim)
        with self.assertRaises(OSError):
            generator.generate(self.secret(), self.shell)
        self.assertEqual(victim.read_text(), "preserved")
        self.assertEqual(victim.stat().st_mode & 0o777, 0o644)

    def test_parent_symlink_is_rejected(self):
        (self.root / "real").mkdir()
        (self.root / "link").symlink_to(self.root / "real")
        with self.assertRaises(OSError):
            generator.generate(self.secret(path="link/value"), self.shell)
        self.assertFalse((self.root / "real/value").exists())

    def test_nonregular_and_hardlinked_files_are_rejected(self):
        (self.root / "value").mkdir()
        with self.assertRaises(ValueError):
            generator.generate(self.secret(), self.shell)
        (self.root / "value").rmdir()
        (self.root / "victim").write_text("preserved")
        os.link(self.root / "victim", self.root / "value")
        with self.assertRaises(ValueError):
            generator.generate(self.secret(), self.shell)
        (self.root / "value").unlink()
        os.mkfifo(self.root / "value")
        with self.assertRaises(ValueError):
            generator.generate(self.secret(), self.shell)

    def test_nested_parent_and_spaces(self):
        generator.generate(self.secret(path="nested dir/another/value"), self.shell)
        self.assertEqual((self.root / "nested dir/another/value").read_text(), "generated")
        self.assertEqual((self.root / "nested dir").stat().st_mode & 0o777, 0o700)

    def test_concurrent_creators_do_not_replace_each_other(self):
        def run(i):
            generator.generate(self.secret(command=f"printf value-{i}"), self.shell)
        with concurrent.futures.ThreadPoolExecutor(max_workers=8) as executor:
            list(executor.map(run, range(24)))
        self.assertRegex((self.root / "value").read_text(), r"^value-\d+$")
        self.assertEqual(len(list(self.root.iterdir())), 1)

    def test_main_never_logs_generated_value(self):
        import json
        config = self.root / "config.json"
        config.write_text(json.dumps(dict(test=self.secret(command="printf secret-sentinel; printf secret-sentinel >&2; exit 5"))))
        result = subprocess.run([shutil.which("python3"), str(Path(__file__).with_name("generate.py")), str(config), self.shell], capture_output=True, text=True)
        self.assertEqual(result.returncode, 1)
        self.assertNotIn("secret-sentinel", result.stdout + result.stderr)


if __name__ == "__main__":
    unittest.main()
