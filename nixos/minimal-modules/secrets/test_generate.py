import concurrent.futures
import grp
import json
import os
import pwd
import shlex
import shutil
import stat
import subprocess
import tempfile
import unittest
from pathlib import Path

program = [os.environ["LANTIAN_SECRETS_GENERATOR"]]


class SecretsTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.specs = tempfile.TemporaryDirectory()
        self.addCleanup(self.specs.cleanup)
        self.shell = shutil.which("bash")

    def secret(self, path="value", command="printf generated", **extra):
        return dict(
            path=str(self.root / path),
            command=command,
            owner=pwd.getpwuid(os.getuid()).pw_name,
            group=grp.getgrgid(os.getgid()).gr_name,
            mode="0600",
            **extra,
        )

    def invoke(self, secrets, shell=None, env=None):
        with tempfile.NamedTemporaryFile(mode="w", dir=self.specs.name) as config:
            json.dump(secrets, config)
            config.flush()
            result = subprocess.run(
                program + [config.name, shell or self.shell],
                capture_output=True,
                text=True,
                timeout=15,
                env=env,
            )
        self.assertEqual(result.stdout, "")
        return result

    def generate(self, secret, error=None, **kwargs):
        result = self.invoke(dict(test=secret), **kwargs)
        self.assertEqual(result.returncode, 1 if error else 0, result.stderr)
        if error:
            self.assertRegex(result.stderr, error)
        else:
            self.assertEqual(result.stderr, "")
        return result

    def test_create_and_preserve_value(self):
        secret = self.secret(command="printf invoked >> count; printf generated")
        self.generate(secret)
        target = self.root / "value"
        first_inode = target.stat().st_ino
        secret["command"] = "exit 99"
        self.generate(secret)
        self.assertEqual(target.read_text(), "generated")
        self.assertEqual(target.stat().st_ino, first_inode)
        self.assertEqual(target.stat().st_mode & 0o777, 0o600)

    def test_empty_existing_file_is_not_regenerated(self):
        (self.root / "value").touch()
        self.generate(self.secret(command="exit 99"))
        self.assertEqual((self.root / "value").read_bytes(), b"")

    def test_mode_update_without_generation(self):
        secret = self.secret()
        self.generate(secret)
        secret.update(mode="0640", command="exit 99")
        self.generate(secret)
        self.assertEqual((self.root / "value").stat().st_mode & 0o777, 0o640)
        self.assertEqual((self.root / "value").read_text(), "generated")

    def test_failure_leaves_no_partial_file_or_output(self):
        secret = self.secret(
            command="printf do-not-log; printf do-not-log >&2; exit 12"
        )
        result = self.generate(secret, error="exit 12")
        self.assertNotIn("do-not-log", result.stderr)
        self.assertEqual(list(self.root.iterdir()), [])

    def test_empty_output_fails(self):
        self.generate(self.secret(command="true"), error="empty")
        self.assertEqual(list(self.root.iterdir()), [])

    def test_final_symlink_is_rejected_without_modification(self):
        victim = self.root / "victim"
        victim.write_text("preserved")
        victim.chmod(0o644)
        (self.root / "value").symlink_to(victim)
        self.generate(self.secret(), error=".")
        self.assertEqual(victim.read_text(), "preserved")
        self.assertEqual(victim.stat().st_mode & 0o777, 0o644)

    def test_dangling_final_symlink_is_rejected(self):
        (self.root / "value").symlink_to(self.root / "absent")
        self.generate(self.secret(), error=".")
        self.assertFalse((self.root / "absent").exists())
        self.assertEqual(len(list(self.root.iterdir())), 1)

    def test_parent_symlink_is_rejected(self):
        (self.root / "real").mkdir()
        (self.root / "link").symlink_to(self.root / "real")
        self.generate(self.secret(path="link/value"), error=".")
        self.assertFalse((self.root / "real/value").exists())

    def test_nonregular_and_hardlinked_files_are_rejected(self):
        (self.root / "value").mkdir()
        self.generate(self.secret(), error="regular file")
        (self.root / "value").rmdir()
        victim = self.root / "victim"
        victim.write_text("preserved")
        victim.chmod(0o644)
        os.link(victim, self.root / "value")
        self.generate(self.secret(), error="regular file")
        self.assertEqual(victim.read_text(), "preserved")
        self.assertEqual(victim.stat().st_mode & 0o777, 0o644)
        (self.root / "value").unlink()
        os.mkfifo(self.root / "value")
        self.generate(self.secret(), error="regular file")
        self.assertTrue(stat.S_ISFIFO((self.root / "value").stat().st_mode))

    def test_nested_parent_and_spaces(self):
        self.generate(self.secret(path="nested dir/another/value"))
        self.assertEqual(
            (self.root / "nested dir/another/value").read_text(), "generated"
        )
        self.assertEqual((self.root / "nested dir").stat().st_mode & 0o777, 0o700)
        self.assertEqual(
            (self.root / "nested dir/another").stat().st_mode & 0o777, 0o700
        )

    def test_existing_parent_mode_is_preserved(self):
        parent = self.root / "parent"
        parent.mkdir(mode=0o755)
        self.generate(self.secret(path="parent/value"))
        self.assertEqual(parent.stat().st_mode & 0o777, 0o755)

    def test_concurrent_creators_do_not_replace_each_other(self):
        def run(i):
            self.generate(self.secret(command=f"printf value-{i}"))

        with concurrent.futures.ThreadPoolExecutor(max_workers=8) as executor:
            list(executor.map(run, range(24)))
        self.assertRegex((self.root / "value").read_text(), r"^value-\d+$")
        self.assertEqual(len(list(self.root.iterdir())), 1)
        self.assertEqual((self.root / "value").stat().st_nlink, 1)

    def test_main_never_logs_generated_value(self):
        result = self.generate(
            self.secret(
                command="printf secret-sentinel; printf secret-sentinel >&2; exit 5"
            ),
            error="exit 5",
        )
        self.assertNotIn("secret-sentinel", result.stdout + result.stderr)

    def test_private_tmpdir_cwd_null_stdin_and_cleanup(self):
        work = self.root / "work"
        work.mkdir()
        env = dict(os.environ, TMPDIR=str(work))
        command = 'test "$(pwd -P)" != "$TMPDIR"; test "$(readlink /proc/$$/fd/0)" = /dev/null; test "$(readlink /proc/$$/fd/2)" = /dev/null; test -f /proc/$$/fd/1; test -z "$(cat)"; printf artifact > artifact; printf "%s\\n" "$PWD"; stat -c %a .; umask; printf hidden-stderr >&2'
        self.generate(self.secret(command=command), env=env)
        cwd, mode, mask = (self.root / "value").read_text().splitlines()
        self.assertEqual(Path(cwd).parent, work)
        self.assertTrue(Path(cwd).name.startswith("lantian-secret-"))
        self.assertEqual(mode, "700")
        self.assertEqual(mask, "0077")
        self.assertFalse(Path(cwd).exists())
        self.assertEqual(list(work.iterdir()), [])
        (self.root / "value").unlink()
        self.generate(
            self.secret(
                command="printf artifact > artifact; printf hidden-stderr >&2; exit 8"
            ),
            error="exit 8",
            env=env,
        )
        self.assertEqual(list(work.iterdir()), [])
        self.assertEqual(sorted(p.name for p in self.root.iterdir()), ["work"])

    def test_shell_strict_flags(self):
        for command in [
            "false; printf should-not-run",
            "false | true; printf should-not-run",
            "printf '%s' \"$UNDEFINED_LANTIAN_SECRET_TEST_VARIABLE\"",
        ]:
            with self.subTest(command=command):
                result = self.generate(
                    self.secret(command=command), error="generator failed"
                )
                self.assertNotIn("should-not-run", result.stderr)
                self.assertEqual(list(self.root.iterdir()), [])

    def test_missing_shell_cleans_up(self):
        self.generate(self.secret(), error=".", shell=str(self.root / "no-shell"))
        self.assertEqual(list(self.root.iterdir()), [])

    def test_signalled_generator_cleans_up(self):
        self.generate(
            self.secret(command="printf do-not-log; kill -TERM $$"), error="exit -15"
        )
        self.assertEqual(list(self.root.iterdir()), [])

    def test_normalized_paths_only(self):
        for path in [
            "",
            "relative",
            "/",
            str(self.root) + "//value",
            str(self.root) + "/./value",
            str(self.root) + "/../value",
            str(self.root) + "/value/",
        ]:
            with self.subTest(path=path):
                secret = self.secret()
                secret["path"] = path
                self.generate(secret, error="absolute normalized file path")
        self.assertEqual(list(self.root.iterdir()), [])

    def test_racing_winner_is_preserved_and_metadata_fixed(self):
        target = self.root / "value"
        command = f"printf winner > {shlex.quote(str(target))}; chmod 644 {shlex.quote(str(target))}; printf loser"
        self.generate(self.secret(command=command))
        self.assertEqual(target.read_text(), "winner")
        self.assertEqual(target.stat().st_mode & 0o777, 0o600)
        self.assertEqual(target.stat().st_nlink, 1)
        self.assertEqual(len(list(self.root.iterdir())), 1)

    def test_racing_invalid_winner_is_rejected(self):
        target = self.root / "value"
        victim = self.root / "victim"
        victim.write_text("preserved")
        victim.chmod(0o644)
        for operation in [
            f"ln -s {shlex.quote(str(victim))}",
            f"ln {shlex.quote(str(victim))}",
            "mkfifo",
            "mkdir",
        ]:
            with self.subTest(operation=operation):
                command = f"{operation} {shlex.quote(str(target))}; printf loser"
                self.generate(self.secret(command=command), error=".")
                self.assertEqual(victim.read_text(), "preserved")
                self.assertEqual(victim.stat().st_mode & 0o777, 0o644)
                self.assertEqual(
                    sorted(p.name for p in self.root.iterdir()), ["value", "victim"]
                )
                if target.is_dir():
                    target.rmdir()
                else:
                    target.unlink()

    def test_parent_fd_remains_pinned_if_path_replaced(self):
        parent = self.root / "parent"
        moved = self.root / "moved"
        parent.mkdir()
        command = f"mv {shlex.quote(str(parent))} {shlex.quote(str(moved))}; mkdir {shlex.quote(str(parent))}; printf generated"
        self.generate(self.secret(path="parent/value", command=command))
        self.assertEqual((moved / "value").read_text(), "generated")
        self.assertEqual(list(parent.iterdir()), [])
        self.assertEqual(len(list(moved.iterdir())), 1)

    def test_binary_output(self):
        self.generate(self.secret(command=r"printf '\000\377\376abc\n'"))
        self.assertEqual((self.root / "value").read_bytes(), b"\x00\xff\xfeabc\n")

    def test_batch_order_and_stop_at_failure(self):
        result = self.invoke(
            {
                "z-first": self.secret(path="first"),
                "a-fail": self.secret(path="failed", command="exit 9"),
                "b-never": self.secret(path="never"),
            }
        )
        self.assertEqual(result.returncode, 1)
        self.assertIn("lantian.secrets a-fail:", result.stderr)
        self.assertEqual((self.root / "first").read_text(), "generated")
        self.assertEqual(sorted(p.name for p in self.root.iterdir()), ["first"])

    def test_group_ownership_and_new_parents(self):
        groups = [gid for gid in os.getgroups() if gid != os.getgid()]
        if not groups:
            self.skipTest("requires an additional group")
        group = grp.getgrgid(groups[0]).gr_name
        secret = self.secret(path="nested/value")
        secret["group"] = group
        self.generate(secret)
        self.assertEqual((self.root / "nested").stat().st_gid, groups[0])
        self.assertEqual((self.root / "nested/value").stat().st_gid, groups[0])
        secret.update(
            group=grp.getgrgid(os.getgid()).gr_name, command="exit 99", mode="0640"
        )
        self.generate(secret)
        self.assertEqual((self.root / "nested/value").stat().st_gid, os.getgid())
        self.assertEqual((self.root / "nested/value").stat().st_mode & 0o777, 0o640)
        self.assertEqual((self.root / "nested").stat().st_gid, groups[0])


if __name__ == "__main__":
    unittest.main()
