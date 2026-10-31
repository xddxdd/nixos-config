use flate2::write::GzEncoder;
use flate2::Compression;
use std::fs;
use std::fs::File;
use std::io::BufRead;
use std::io::BufReader;
use std::io::Read;
use std::io::Seek;
use std::io::Write;
use std::path::Path;

const CHUNK_SIZE: usize = 64 * 1024;

pub fn file_size(path: String) -> Result<u64, std::io::Error> {
    match File::open(path) {
        Ok(f) => match f.metadata() {
            Ok(metadata) => Ok(metadata.len()),
            Err(e) => Err(e),
        },
        Err(e) => Err(e),
    }
}

fn chunked_read_write(file: String, writer: &mut Box<dyn Write>) -> Result<u64, std::io::Error> {
    let mut input_file = match File::open(file.clone()) {
        Ok(file) => file,
        Err(e) => return Err(e),
    };

    let input_size = match Read::by_ref(&mut input_file).metadata() {
        Ok(metadata) => metadata.len(),
        Err(e) => return Err(e),
    };

    let mut reader = BufReader::with_capacity(CHUNK_SIZE, input_file);

    loop {
        let buffer = match reader.fill_buf() {
            Ok(buf) => buf.to_owned(),
            Err(e) => return Err(e),
        };
        reader.consume(buffer.len());
        if buffer.len() > 0 {
            match writer.write_all(&buffer) {
                Ok(_) => (),
                Err(e) => return Err(e),
            };
        }
        if buffer.len() < CHUNK_SIZE {
            break;
        }
    }

    match writer.flush() {
        Ok(_) => (),
        Err(e) => return Err(e),
    };

    return Ok(input_size);
}

fn compress_to_writer(
    file: String,
    max_size: u64,
    compress_name: &str,
    compress_ext: &str,
    writer: fn(w: Box<dyn Write>) -> Box<dyn Write>,
) -> Result<u64, std::io::Error> {
    let output_path = format!("{}.{}", file, compress_ext);

    if Path::new(&output_path).exists() {
        let file_size = match file_size(output_path.clone()) {
            Ok(len) => len,
            Err(e) => return Err(e),
        };

        println!(
            "{} already {} compressed to {} bytes",
            file, compress_name, file_size
        );
        return Ok(file_size);
    }

    let mut output_file = match File::create(output_path.clone()) {
        Ok(f) => f,
        Err(e) => return Err(e),
    };

    // Create a cloned output file object for writer
    let mut e = writer(match output_file.try_clone() {
        Ok(f) => Box::new(f),
        Err(e) => return Err(e),
    });

    let input_size = match chunked_read_write(file.clone(), &mut e) {
        Ok(size) => size,
        Err(e) => return Err(e),
    };

    // Destruct object to write everything into output file
    std::mem::drop(e);

    let output_size = match Write::by_ref(&mut output_file).seek(std::io::SeekFrom::Current(0)) {
        Ok(pos) => pos,
        Err(e) => return Err(e),
    };

    // Destruct object to flush output file
    std::mem::drop(output_file);

    if output_size < max_size {
        println!(
            "{} compress {}: {} -> {} bytes (max acceptable {})",
            compress_name, file, input_size, output_size, max_size,
        );
    } else {
        println!(
            "{} compress {}: {} -> {} bytes (max acceptable {}), deleting",
            compress_name, file, input_size, output_size, max_size,
        );

        match fs::remove_file(output_path.clone()) {
            Ok(_) => (),
            Err(e) => return Err(e),
        }
    }
    return Ok(output_size);
}

pub fn gzip(file: String, max_size: u64) -> Result<u64, std::io::Error> {
    compress_to_writer(file, max_size, "Gzip", "gz", |w| {
        Box::new(GzEncoder::new(w, Compression::best()))
    })
}

pub fn brotli(file: String, max_size: u64) -> Result<u64, std::io::Error> {
    compress_to_writer(file, max_size, "Brotli", "br", |w| {
        Box::new(brotli::CompressorWriter::new(w, CHUNK_SIZE, 11, 22))
    })
}

pub fn zstd(file: String, max_size: u64) -> Result<u64, std::io::Error> {
    compress_to_writer(file, max_size, "Zstd", "zst", |w| {
        Box::new(zstd::Encoder::new(w, 19).unwrap())
    })
}
