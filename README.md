# YouTube downloader

`download-youtube` is a shell wrapper around [yt-dlp](https://github.com/yt-dlp/yt-dlp)
and [FFmpeg](https://ffmpeg.org/) for downloading one YouTube video at a time.
Run it as `download-youtube` or `yt` after installation. It defaults to the
highest available resolution and saves to your current directory.

## Installation

1. Install `yt-dlp` and FFmpeg and make sure both are on your `PATH`. On macOS
   with Homebrew:

   ```sh
   brew install yt-dlp ffmpeg
   ```

   On other systems, use the upstream installation instructions linked above.
   Listing formats only needs `yt-dlp`. The script runs in `sh`; Node.js and
   npm are not required.

2. If you haven't cloned the project, use the GitHub CLI from an account with
   access to the repository:

   ```sh
   gh repo clone yabasha/download-youtube
   cd download-youtube
   ```

3. From the repository root, install the command and its shorthand for your
   user. If either name is already in use, check it before replacing it.

   ```sh
   mkdir -p "$HOME/.local/bin"
   install -m 755 download-youtube.sh "$HOME/.local/bin/download-youtube"
   ln -s download-youtube "$HOME/.local/bin/yt"
   ```

4. If `~/.local/bin` is not already on your `PATH`, run the following in your
   shell. Add the same line to `~/.zshrc` to keep it for future zsh sessions.

   ```sh
   export PATH="$HOME/.local/bin:$PATH"
   ```

5. Verify both commands resolve and try listing formats without downloading:

   ```sh
   download-youtube --help
   yt -F "https://youtu.be/jNQXAC9IVRw"
   ```

To use the script without installing it, run `./download-youtube.sh --help`
from the repository root.

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

## Troubleshooting

- **`yt: command not found`:** Check that `~/.local/bin` is on your `PATH`.
  If you skipped installation, run `./download-youtube.sh` from the repository.
- **A dependency is missing:** Run `yt-dlp --version` and `ffmpeg -version`
  to check that both are available in the same shell.
- **Requested format is unavailable:** Run `yt -F "YOUTUBE_URL"` and choose
  a listed video height, or omit `-r` to let the script pick automatically.

## License

[MIT](LICENSE)
