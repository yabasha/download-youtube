# YouTube downloader

`download-youtube` is a shell wrapper around [yt-dlp](https://github.com/yt-dlp/yt-dlp)
and [FFmpeg](https://ffmpeg.org/) for downloading one YouTube video at a time.
Run it as `download-youtube` or `yt` after installation. It defaults to the
highest available resolution and saves to your current directory.

## Why I made this

I wanted a quick way to download YouTube videos straight to my machine. The
download sites I tried were full of ads and spam, and they often capped the
resolution. I made this wrapper so I could paste a link into my terminal and
get the best available video and audio without going through those sites.

## Installation

1. If you haven't cloned the project, use the GitHub CLI from an account with
   access to the repository:

   ```sh
   gh repo clone yabasha/download-youtube
   cd download-youtube
   ```

2. From the repository root, run the installer:

   ```sh
   ./install.sh
   ```

   The installer checks for `yt-dlp` and FFmpeg on your `PATH`. If either is
   missing, it shows the `brew install` command for just the missing tools.
   If Homebrew is available, answer `y` to let the installer run the command.
   If you decline, press Enter, or run without an interactive terminal, it stops
   without installing anything. Run the printed command manually and rerun
   `./install.sh`. Without Homebrew, use your system's package manager or the
   upstream installation instructions linked above.

   Once both tools are available, it sets up `download-youtube` and `yt` in
   `~/.local/bin` without overwriting a different command at either path.
   Node.js and npm are not required.

3. If `~/.local/bin` is not already on your `PATH`, run the following in your
   shell. Add the same line to `~/.zshrc` to keep it for future zsh sessions.

   ```sh
   export PATH="$HOME/.local/bin:$PATH"
   ```

4. Verify both commands resolve and try listing formats without downloading:

   ```sh
   download-youtube --help
   yt -F "https://youtu.be/jNQXAC9IVRw"
   ```

To use the script without installing it, run `./download-youtube.sh --help`
from the repository root. The downloader does not install tools on its own,
and listing formats only requires `yt-dlp`.

## Usage

Omit the URL to enter it at the prompt. Quote URLs passed on the command line,
especially those containing query parameters.

```sh
yt
download-youtube "https://youtu.be/NE84ZYfnniU"
yt -F "https://youtu.be/NE84ZYfnniU"
yt -r 1080p -d "$HOME/Downloads/AI Videos" "https://youtu.be/NE84ZYfnniU"
yt -k "https://youtu.be/NE84ZYfnniU"
```

The script accepts YouTube watch URLs (`youtube.com/watch?v=…`), `youtu.be`
short links, and video URLs under `/shorts/`, `/live/`, or `/embed/`. It does
not accept playlist or channel links.

## Options

- `-F`, `--list-resolutions`, `--list-formats`: List available formats and
  resolutions without downloading.
- `-r HEIGHT`, `--resolution HEIGHT`: Require an exact video height, such as
  `1080` or `1080p`. If it is unavailable, use `-F` to see the available options.
- `-d DIR`, `--destination DIR`: Save to `DIR` instead of the current directory.
  Quote paths that contain spaces.
- `-k`, `--keep-video`: Retain the separate video and audio files after merging.
  By default, only the merged file is kept.
- `-h`, `--help`: Show the built-in help.

Downloads are named `Video title [VIDEO_ID].ext`. Separate video and audio
downloads are merged into MKV. If no merge is needed, the extension depends
on the selected format. Existing files are not overwritten.
Git ignores files matching the downloader's output names, including partial
downloads, when they are saved inside this repository.

## Test a download

From the repository root, run the live smoke test:

```sh
sh tests/smoke.sh
```

It downloads a short sample to a temporary folder, verifies that the file
contains video and audio with `ffprobe`, and removes the test files when it
exits. The test requires internet access, `yt-dlp`, and FFmpeg (including
`ffprobe`) on your `PATH`. To test a different short video, pass its URL as
an argument: `sh tests/smoke.sh "YOUTUBE_URL"`.

## Troubleshooting

- **`yt: command not found`:** Check that `~/.local/bin` is on your `PATH`.
  If you skipped installation, run `./download-youtube.sh` from the repository.
- **A dependency is missing:** Run `yt-dlp --version` and `ffmpeg -version`
  to check that both are available in the same shell.
- **Requested format is unavailable:** Run `yt -F "YOUTUBE_URL"` and choose
  a listed video height, or omit `-r` to let the script pick automatically.

## License

The script is free to use under the [MIT license](LICENSE). Run it as-is or
modify it to fit your needs.
