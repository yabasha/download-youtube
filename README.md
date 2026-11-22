# YouTube downloader

`download-youtube` is a shell wrapper around [yt-dlp](https://github.com/yt-dlp/yt-dlp)
and [FFmpeg](https://ffmpeg.org/) for downloading one YouTube video at a time.
Run it as `download-youtube` or `yt` after installation. It defaults to the
highest available resolution and saves to your current directory.

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

## Requirements

`yt-dlp` and FFmpeg must be on your `PATH` for downloads. Listing formats
only requires `yt-dlp`. These are system tools, not npm dependencies. The
script runs in `sh` and does not require Node.js or npm.

## Install the commands

From the repository root, run these commands if `download-youtube` and `yt`
are not already installed:

```sh
mkdir -p "$HOME/.local/bin"
install -m 755 download-youtube.sh "$HOME/.local/bin/download-youtube"
ln -s download-youtube "$HOME/.local/bin/yt"
```

If `~/.local/bin` is not on your `PATH`, add this line to `~/.zshrc` and open
a new terminal:

```sh
export PATH="$HOME/.local/bin:$PATH"
```

Run `yt --help` to verify the installation. You can also run
`./download-youtube.sh` directly from the repository without installing it.

## Troubleshooting

- **`yt: command not found`:** Check that `~/.local/bin` is on your `PATH`.
  If you skipped installation, run `./download-youtube.sh` from the repository.
- **A dependency is missing:** Run `yt-dlp --version` and `ffmpeg -version`
  to check that both are available in the same shell.
- **Requested format is unavailable:** Run `yt -F "YOUTUBE_URL"` and choose
  a listed video height, or omit `-r` to let the script pick automatically.

## License

[MIT](LICENSE)
