//! Read-only `mmap` wrapper for the packed corpus file.

use std::fs::File;
use std::io;
use std::ops::Deref;
use std::path::Path;

pub struct Mmap {
    map: memmap2::Mmap,
}

impl Mmap {
    pub fn open(path: &Path) -> io::Result<Mmap> {
        let file = File::open(path)?;
        let map = unsafe { memmap2::Mmap::map(&file)? };
        // The corpus is read through scattered indices; tell the kernel not to
        // bother with readahead. Best effort, failure is harmless.
        let _ = map.advise(memmap2::Advice::Random);
        Ok(Mmap { map })
    }
}

impl Deref for Mmap {
    type Target = [u8];

    fn deref(&self) -> &[u8] {
        &self.map[..]
    }
}
