# download-youtube

This is a POSIX shell CLI for downloading YouTube videos with `yt-dlp` and FFmpeg. Run `./download-youtube.sh` from the checkout or `download-youtube` and `yt` after installation. Keep shell changes compatible with `/bin/sh`. `package.json` provides private package metadata and command mappings. The CLI runs independently of Node.js.

## Where to work

- CLI options, URL validation, batch input, and format selection live in [`download-youtube.sh`](download-youtube.sh). The wrapper gathers URLs from arguments, batch files, or a prompt and passes them to one `yt-dlp` process over stdin. Format listing requires only `yt-dlp`. Downloads also require FFmpeg.
- Installation and dependency setup live in [`install.sh`](install.sh). It copies the script to `~/.local/bin/download-youtube`, creates the `yt` symlink, and protects existing commands at both paths. It asks before running Homebrew for missing tools. Use the checkout entry point for CLI verification so it exercises the current source.
- For CLI usage, install steps, or troubleshooting, see [`README.md`](README.md). Keep the README and `--help` in sync when changing user-facing behavior.

## CLI behavior

- Mixed argument and batch inputs retain their input order. Batch files accept CRLF and a final line without a newline, and skip empty lines and lines starting with `#`. Keep paths with spaces intact.
- Downloads default to the highest available resolution and the current directory. `-r` requests an exact video height. Keep existing files intact. When separate streams need merging, use MKV and retain the original streams only with `-k`.
- Both download and format-listing modes pass `--no-playlist` to `yt-dlp` so video URLs with `list=` select only the linked video. Standalone playlist URLs fail validation.

## Verification

Run from the repository root after shell changes.

```sh
for script in download-youtube.sh install.sh tests/smoke.sh; do
  sh -n "$script" || exit 1
done
./download-youtube.sh --help
```

For parser or argument changes, put a stub `yt-dlp` first on `PATH` and inspect the arguments and stdin. For download or merge changes, run `sh tests/smoke.sh` with internet access and `yt-dlp`, `ffmpeg`, and `ffprobe` on `PATH`. The [smoke test](tests/smoke.sh) downloads a short public sample into a temporary directory, verifies that the output contains audio and video, and cleans up on exit. Report which checks ran and flag any blocked live check.
