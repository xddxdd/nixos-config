import ctypes
import errno
import grp
import json
import os
import pwd
import secrets
import stat
import subprocess
import sys
import tempfile


def open_parent(path, uid, gid):
    parts = path.split("/")
    if parts[0] or not parts[-1] or any(p in ("", ".", "..") for p in parts[1:]):
        raise ValueError("destination must be an absolute normalized file path")
    fd = os.open("/", os.O_RDONLY | os.O_DIRECTORY)
    try:
        for part in parts[1:-1]:
            try:
                child = os.open(part, os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW, dir_fd=fd)
            except FileNotFoundError:
                created = False
                try:
                    os.mkdir(part, mode=0o700, dir_fd=fd)
                    created = True
                except FileExistsError:
                    pass
                child = os.open(part, os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW, dir_fd=fd)
                if created:
                    try:
                        os.fchown(child, uid, gid)
                    except BaseException:
                        os.close(child)
                        raise
            os.close(fd)
            fd = child
        return fd, parts[-1]
    except BaseException:
        os.close(fd)
        raise


def metadata(fd, uid, gid, mode):
    current = os.fstat(fd)
    if not stat.S_ISREG(current.st_mode) or current.st_nlink != 1:
        raise ValueError("destination must be a regular file with no other hard links")
    if (current.st_uid, current.st_gid) != (uid, gid):
        os.fchown(fd, uid, gid)
    if stat.S_IMODE(os.fstat(fd).st_mode) != mode:
        os.fchmod(fd, mode)


def existing(parent, name, uid, gid, mode):
    try:
        fd = os.open(name, os.O_RDONLY | os.O_NONBLOCK | os.O_NOFOLLOW, dir_fd=parent)
    except FileNotFoundError:
        return False
    try:
        metadata(fd, uid, gid, mode)
    finally:
        os.close(fd)
    return True


def generate(secret, shell):
    uid = pwd.getpwnam(secret["owner"]).pw_uid
    gid = grp.getgrnam(secret["group"]).gr_gid
    mode = int(secret["mode"], 8)
    parent, name = open_parent(secret["path"], uid, gid)
    temporary = ".lantian-secret-" + secrets.token_hex(16)
    created = False
    try:
        if existing(parent, name, uid, gid, mode):
            return
        fd = os.open(temporary, os.O_WRONLY | os.O_CREAT | os.O_EXCL | os.O_NOFOLLOW, 0o600, dir_fd=parent)
        created = True
        try:
            with tempfile.TemporaryDirectory(prefix="lantian-secret-") as work:
                # Neither generator stderr nor its stdout may enter the journal.
                result = subprocess.run([shell, "-euo", "pipefail", "-c", secret["command"]], cwd=work, stdin=subprocess.DEVNULL, stdout=fd, stderr=subprocess.DEVNULL)
            if result.returncode:
                raise RuntimeError("generator failed (exit " + str(result.returncode) + ")")
            if os.fstat(fd).st_size == 0:
                raise RuntimeError("generator produced an empty value")
            metadata(fd, uid, gid, mode)
            os.fsync(fd)
        finally:
            os.close(fd)
        # Linux renameat2(RENAME_NOREPLACE) publishes a complete file without
        # overwriting a racing creator or briefly creating a second hard link.
        libc = ctypes.CDLL(None, use_errno=True)
        rename = libc.renameat2
        rename.argtypes = [ctypes.c_int, ctypes.c_char_p, ctypes.c_int, ctypes.c_char_p, ctypes.c_uint]
        rename.restype = ctypes.c_int
        if rename(parent, os.fsencode(temporary), parent, os.fsencode(name), 1):
            error = ctypes.get_errno()
            if error != errno.EEXIST:
                raise OSError(error, os.strerror(error))
            if not existing(parent, name, uid, gid, mode):
                raise RuntimeError("racing destination disappeared")
            os.unlink(temporary, dir_fd=parent)
        created = False
        os.fsync(parent)
    finally:
        if created:
            os.unlink(temporary, dir_fd=parent)
        os.close(parent)


def main():
    with open(sys.argv[1]) as f:
        specification = json.load(f)
    os.umask(0o077)
    for name, secret in specification.items():
        try:
            generate(secret, sys.argv[2])
        except (OSError, ValueError, KeyError, RuntimeError) as error:
            print("lantian.secrets " + name + ": " + str(error), file=sys.stderr)
            return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
