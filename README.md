# YouTube downloader

Use `download-youtube` or its shorthand `yt` from any directory. The script
downloads one YouTube video at the highest available resolution by default
and saves it in your current directory. If you omit the URL, it prompts you
for one. Quote URLs you pass on the command line, especially those containing
query parameters.

## Usage

```sh
yt
download-youtube "https://youtu.be/NE84ZYfnniU"
yt -F "https://youtu.be/NE84ZYfnniU"
yt -r 1080p -d "$HOME/Downloads/AI Videos" "https://youtu.be/NE84ZYfnniU"
yt -k "https://youtu.be/NE84ZYfnniU"
```

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

Separate streams are merged into an MKV file when needed. Existing files are
not overwritten, and playlists are not downloaded.

## Requirements

`yt-dlp` and FFmpeg must be on your `PATH` for downloads. Listing formats
only requires `yt-dlp`.

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
