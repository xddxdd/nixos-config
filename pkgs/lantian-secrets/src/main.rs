use serde_json::Value;
use std::env;
use std::ffi::{CStr, CString, OsStr};
use std::fs::File;
use std::io;
use std::os::fd::{AsRawFd, FromRawFd};
use std::os::unix::fs::{MetadataExt, PermissionsExt};
use std::os::unix::process::ExitStatusExt;
use std::process::{Command, Stdio};

fn checked(result: libc::c_int) -> io::Result<()> {
    if result == -1 {
        Err(io::Error::last_os_error())
    } else {
        Ok(())
    }
}

fn cstring(value: &str) -> io::Result<CString> {
    CString::new(value).map_err(io::Error::other)
}

fn open_at(parent: &File, name: &CStr, flags: libc::c_int) -> io::Result<File> {
    let fd = unsafe {
        libc::openat(
            parent.as_raw_fd(),
            name.as_ptr(),
            flags | libc::O_CLOEXEC,
            0o600 as libc::mode_t,
        )
    };
    checked(fd)?;
    Ok(unsafe { File::from_raw_fd(fd) })
}

fn chown(file: &File, uid: libc::uid_t, gid: libc::gid_t) -> io::Result<()> {
    checked(unsafe { libc::fchown(file.as_raw_fd(), uid, gid) })
}

fn open_parent(path: &str, uid: libc::uid_t, gid: libc::gid_t) -> io::Result<(File, CString)> {
    let parts: Vec<_> = path.split('/').collect();
    if parts.len() < 2
        || !parts[0].is_empty()
        || parts[1..].iter().any(|p| matches!(*p, "" | "." | ".."))
    {
        return Err(io::Error::other(
            "destination must be an absolute normalized file path",
        ));
    }
    let fd = unsafe {
        libc::open(
            c"/".as_ptr(),
            libc::O_RDONLY | libc::O_DIRECTORY | libc::O_CLOEXEC,
        )
    };
    checked(fd)?;
    let mut parent = unsafe { File::from_raw_fd(fd) };
    for part in &parts[1..parts.len() - 1] {
        let name = cstring(part)?;
        parent = match open_at(
            &parent,
            &name,
            libc::O_RDONLY | libc::O_DIRECTORY | libc::O_NOFOLLOW,
        ) {
            Ok(child) => child,
            Err(error) if error.kind() == io::ErrorKind::NotFound => {
                let result =
                    checked(unsafe { libc::mkdirat(parent.as_raw_fd(), name.as_ptr(), 0o700) });
                let created = match result {
                    Ok(()) => true,
                    Err(error) if error.kind() == io::ErrorKind::AlreadyExists => false,
                    Err(error) => return Err(error),
                };
                let child = open_at(
                    &parent,
                    &name,
                    libc::O_RDONLY | libc::O_DIRECTORY | libc::O_NOFOLLOW,
                )?;
                if created {
                    chown(&child, uid, gid)?;
                }
                child
            }
            Err(error) => return Err(error),
        };
    }
    Ok((parent, cstring(parts.last().unwrap())?))
}

fn metadata(file: &File, uid: libc::uid_t, gid: libc::gid_t, mode: u32) -> io::Result<()> {
    let current = file.metadata()?;
    if !current.is_file() || current.nlink() != 1 {
        return Err(io::Error::other(
            "destination must be a regular file with no other hard links",
        ));
    }
    if (current.uid(), current.gid()) != (uid, gid) {
        chown(file, uid, gid)?;
    }
    if file.metadata()?.mode() & 0o7777 != mode {
        file.set_permissions(std::fs::Permissions::from_mode(mode))?;
    }
    Ok(())
}

fn existing(
    parent: &File,
    name: &CStr,
    uid: libc::uid_t,
    gid: libc::gid_t,
    mode: u32,
) -> io::Result<bool> {
    match open_at(
        parent,
        name,
        libc::O_RDONLY | libc::O_NONBLOCK | libc::O_NOFOLLOW,
    ) {
        Ok(file) => {
            metadata(&file, uid, gid, mode)?;
            Ok(true)
        }
        Err(error) if error.kind() == io::ErrorKind::NotFound => Ok(false),
        Err(error) => Err(error),
    }
}

fn text<'a>(secret: &'a Value, field: &str) -> io::Result<&'a str> {
    secret[field]
        .as_str()
        .ok_or_else(|| io::Error::other(format!("missing or invalid field {field}")))
}

fn generate(secret: &Value, shell: &OsStr) -> io::Result<()> {
    let owner = cstring(text(secret, "owner")?)?;
    let group = cstring(text(secret, "group")?)?;
    // NSS lookups finish before spawning a child; their static storage is not shared.
    let uid = unsafe {
        let entry = libc::getpwnam(owner.as_ptr());
        if entry.is_null() {
            return Err(io::Error::other("unknown owner"));
        }
        (*entry).pw_uid
    };
    let gid = unsafe {
        let entry = libc::getgrnam(group.as_ptr());
        if entry.is_null() {
            return Err(io::Error::other("unknown group"));
        }
        (*entry).gr_gid
    };
    let mode = u32::from_str_radix(text(secret, "mode")?, 8).map_err(io::Error::other)?;
    let (parent, name) = open_parent(text(secret, "path")?, uid, gid)?;
    let mut random = [0u8; 16];
    let mut remaining = random.as_mut_slice();
    while !remaining.is_empty() {
        let count = unsafe { libc::getrandom(remaining.as_mut_ptr().cast(), remaining.len(), 0) };
        if count < 0 {
            let error = io::Error::last_os_error();
            if error.kind() == io::ErrorKind::Interrupted {
                continue;
            }
            return Err(error);
        }
        remaining = &mut remaining[count as usize..];
    }
    let temporary = cstring(&format!(
        ".lantian-secret-{:032x}",
        u128::from_ne_bytes(random)
    ))?;
    let mut created = false;
    let result = (|| {
        if existing(&parent, &name, uid, gid, mode)? {
            return Ok(());
        }
        let file = open_at(
            &parent,
            &temporary,
            libc::O_WRONLY | libc::O_CREAT | libc::O_EXCL | libc::O_NOFOLLOW,
        )?;
        created = true;
        let work = tempfile::Builder::new()
            .prefix("lantian-secret-")
            .tempdir()?;
        // Generator output goes only to the temporary inode, never to the journal.
        let status = Command::new(shell)
            .args(["-euo", "pipefail", "-c", text(secret, "command")?])
            .current_dir(work.path())
            .stdin(Stdio::null())
            .stdout(Stdio::from(file.try_clone()?))
            .stderr(Stdio::null())
            .status();
        work.close()?;
        let status = status?;
        if !status.success() {
            let code = status
                .code()
                .unwrap_or_else(|| -status.signal().unwrap_or(0));
            return Err(io::Error::other(format!("generator failed (exit {code})")));
        }
        if file.metadata()?.len() == 0 {
            return Err(io::Error::other("generator produced an empty value"));
        }
        metadata(&file, uid, gid, mode)?;
        file.sync_all()?;
        drop(file);
        // Never overwrite a racing creator or introduce a second hard link.
        let publish = checked(unsafe {
            libc::renameat2(
                parent.as_raw_fd(),
                temporary.as_ptr(),
                parent.as_raw_fd(),
                name.as_ptr(),
                libc::RENAME_NOREPLACE,
            )
        });
        if let Err(error) = publish {
            if error.raw_os_error() != Some(libc::EEXIST) {
                return Err(error);
            }
            if !existing(&parent, &name, uid, gid, mode)? {
                return Err(io::Error::other("racing destination disappeared"));
            }
            checked(unsafe { libc::unlinkat(parent.as_raw_fd(), temporary.as_ptr(), 0) })?;
        }
        created = false;
        parent.sync_all()
    })();
    if created {
        checked(unsafe { libc::unlinkat(parent.as_raw_fd(), temporary.as_ptr(), 0) })?;
    }
    result
}

fn run() -> io::Result<()> {
    let mut args = env::args_os().skip(1);
    let specification = args
        .next()
        .ok_or_else(|| io::Error::other("expected specification and shell paths"))?;
    let shell = args
        .next()
        .ok_or_else(|| io::Error::other("expected specification and shell paths"))?;
    let specification: Value =
        serde_json::from_reader(File::open(specification)?).map_err(io::Error::other)?;
    let secrets = specification
        .as_object()
        .ok_or_else(|| io::Error::other("specification must be an object"))?;
    unsafe { libc::umask(0o077) };
    for (name, secret) in secrets {
        generate(secret, &shell)
            .map_err(|error| io::Error::other(format!("lantian.secrets {name}: {error}")))?;
    }
    Ok(())
}

fn main() {
    if let Err(error) = run() {
        eprintln!("{error}");
        std::process::exit(1);
    }
}
