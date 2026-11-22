#!/bin/sh

usage() {
  cat <<EOF
Usage: ${0##*/} [OPTIONS] [YOUTUBE_URL]

Download one YouTube video at the highest available resolution by default.
Omit the URL to enter it when prompted. Files save in the current directory
unless you set a destination. Separate streams are merged to MKV when needed.

Options:
  -d, --destination DIR   Save to DIR instead of the current directory.
  -F, --list-resolutions  Show available formats and resolutions without downloading.
  -r, --resolution HEIGHT Download at the exact video height, e.g. 1080 or 1080p.
  -k, --keep-video         Keep original video and audio files after merging.
  -h, --help               Show this help message and exit.

Examples:
  ${0##*/}
  ${0##*/} -F "https://youtu.be/VIDEO_ID"
  ${0##*/} -r 1080p -d "\$HOME/Downloads" "https://youtu.be/VIDEO_ID"

Requires yt-dlp and, for downloads, ffmpeg. Existing files are not overwritten.
EOF
}

keep_video=0
list_resolutions=0
destination=.
resolution=
url_provided=0
options_done=0
while [ "$#" -gt 0 ]; do
  if [ "$options_done" -eq 0 ]; then
    case "$1" in
      -h|--help)
        usage
        exit 0
        ;;
      -k|--keep-video)
        keep_video=1
        shift
        continue
        ;;
      -F|--list-resolutions|--list-formats)
        list_resolutions=1
        shift
        continue
        ;;
      -d|--destination|-r|--resolution)
        case "${2-}" in
          ''|-*)
            printf 'Error: %s requires a value.\n' "$1" >&2
            exit 1
            ;;
        esac
        case "$1" in
          -d|--destination)
            destination=$2
            ;;
          -r|--resolution)
            resolution=${2%p}
            case "$resolution" in
              ''|0*|*[!0-9]*)
                printf 'Error: resolution must be a positive video height, such as 1080p.\n' >&2
                exit 1
                ;;
            esac
            ;;
        esac
        shift 2
        continue
        ;;
      --)
        options_done=1
        shift
        continue
        ;;
      -*)
        printf 'Error: unknown option: %s\n' "$1" >&2
        usage >&2
        exit 1
        ;;
    esac
  fi

  if [ "$url_provided" -eq 1 ]; then
    printf 'Error: provide at most one URL.\n' >&2
    usage >&2
    exit 1
  fi
  url=$1
  url_provided=1
  shift
done

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    printf 'Error: %s is required but was not found in PATH. Install it before running this script.\n' "$1" >&2
    exit 1
  fi
}

require_command yt-dlp
if [ "$list_resolutions" -eq 0 ]; then
  require_command ffmpeg
fi

if [ "$url_provided" -eq 0 ]; then
  printf 'YouTube URL: '
  IFS= read -r url || exit 1
fi

if [ -z "$url" ]; then
  printf 'Error: a video URL is required.\n' >&2
  exit 1
fi

case "$url" in
  *[[:space:]]*)
    printf 'Error: the URL must not contain whitespace.\n' >&2
    exit 1
    ;;
esac

if ! printf '%s\n' "$url" | LC_ALL=C grep -Eq '^https?://(((www|m|music)\.)?youtube\.com/(watch\?([^#&[:space:]]+&)*v=[A-Za-z0-9_-]{11}([&#][^[:space:]]*)?|(shorts|live|embed)/[A-Za-z0-9_-]{11}([?&#][^[:space:]]*)?)|(www\.)?youtu\.be/[A-Za-z0-9_-]{11}([?&#][^[:space:]]*)?)$'; then
  printf 'Error: enter a valid YouTube video URL (watch, youtu.be, shorts, live, or embed).\n' >&2
  exit 1
fi

if [ "$list_resolutions" -eq 1 ]; then
  exec yt-dlp --ignore-config --no-playlist --list-formats -- "$url"
fi

formats='bestvideo*+bestaudio/best'
if [ -n "$resolution" ]; then
  formats="bestvideo*[height=$resolution]+bestaudio/best[height=$resolution]"
fi

set -- --ignore-config --no-playlist --no-overwrites \
  --format-sort-force -S res \
  -f "$formats" \
  --paths "home:$destination" \
  --merge-output-format mkv \
  -o '%(title)s [%(id)s].%(ext)s'

if [ "$keep_video" -eq 1 ]; then
  set -- "$@" --keep-video
fi

exec yt-dlp "$@" -- "$url"
