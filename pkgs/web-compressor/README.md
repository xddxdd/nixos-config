# Web-Compressor

A simple Rust program that pre-compresses your static web assets.

## Usage

```bash
./web-compressor --target path/to/compress
```

This program will compress **everything** in the target folder into:

- Gzip `.gz`: only if smaller than original file
- Brotli `.br`: only if smaller than original file and Gzip
- Zstd `.zst`: only if smaller than original file, Gzip and Brotli

This program will run compression steps in parallel, utilizing all CPU cores.

All options:

```bash
Usage: web-compressor [OPTIONS] --target <TARGET>

Options:
  -t, --target <TARGET>            Folder to compress
  -i, --include-ext <INCLUDE_EXT>  Extensions to be compressed [default: html,css,js,atom,stl,xml,svg,json,txt]
  -e, --exclude-ext <EXCLUDE_EXT>  Extensions to be not compressed [default: ]
  -g, --gzip                       Enable Gzip compression
  -b, --brotli                     Enable Brotli compression
  -z, --zstd                       Enable Zstd compression
  -h, --help                       Print help
  -V, --version                    Print version
```

## License

Unlicense.
