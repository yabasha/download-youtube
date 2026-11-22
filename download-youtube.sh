#!/bin/sh

usage() {
  cat <<EOF
Usage: ${0##*/} [OPTIONS] [YOUTUBE_URL ...]

Download YouTube videos at the highest available resolution by default.
Each URL selects one video, even if it includes a playlist parameter.
Pass URLs as separate arguments or use -a to read one per line from a file.
With neither, the script prompts for one URL. Files save in the current
directory unless you set a destination.

Options:
  -a, --batch-file FILE     Read one YouTube URL per line from FILE.
  -d, --destination DIR     Save to DIR instead of the current directory.
  -F, --list-resolutions    Show available formats and resolutions without downloading.
  -r, --resolution HEIGHT  Download at the exact video height, e.g. 1080 or 1080p.
  -k, --keep-video          Keep original video and audio files after merging.
  -h, --help                Show this help message and exit.

Examples:
  ${0##*/}
  ${0##*/} "https://youtu.be/VIDEO_ID_1" "https://youtu.be/VIDEO_ID_2"
  ${0##*/} -a urls.txt
  ${0##*/} -F "https://youtu.be/VIDEO_ID"
  ${0##*/} -r 1080p -d "\$HOME/Downloads" "https://youtu.be/VIDEO_ID"

Requires yt-dlp and, for downloads, ffmpeg. Existing files are not overwritten.
EOF
}

fail() {
  printf 'Error: %s\n' "$1" >&2
  exit 1
}

add_url() {
  [ -n "$1" ] || fail "${2-Video URL}: a video URL is required."
  case "$1" in
    *[[:space:]]*) fail "${2-Video URL}: the URL must not contain whitespace." ;;
  esac

  if ! printf '%s\n' "$1" | LC_ALL=C grep -Eq '^https?://(((www|m|music)\.)?youtube\.com/(watch\?([^#&[:space:]]+&)*v=[A-Za-z0-9_-]{11}([&#][^[:space:]]*)?|(shorts|live|embed)/[A-Za-z0-9_-]{11}([?&#][^[:space:]]*)?)|(www\.)?youtu\.be/[A-Za-z0-9_-]{11}([?&#][^[:space:]]*)?)$'; then
    fail "${2-Video URL}: enter a valid YouTube video URL (watch, youtu.be, shorts, live, or embed)."
  fi

  if [ -n "$urls" ]; then
    urls="$urls
$1"
  else
    urls=$1
  fi
}

read_batch() {
  [ -f "$1" ] && [ -r "$1" ] || fail "cannot read batch file: $1"
  line_number=0
  cr=$(printf '\r')
  while IFS= read -r batch_url || [ -n "$batch_url" ]; do
    line_number=$((line_number + 1))
    batch_url=${batch_url%"$cr"}
    case "$batch_url" in
      ''|\#*) continue ;;
    esac
    add_url "$batch_url" "$1:$line_number"
  done < "$1"
}

keep_video=0
list_resolutions=0
destination=.
resolution=
urls=
batch_requested=0
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
      -a|--batch-file|-d|--destination|-r|--resolution)
        case "${2-}" in
          ''|-*)
            printf 'Error: %s requires a value.\n' "$1" >&2
            exit 1
            ;;
        esac
        case "$1" in
          -a|--batch-file)
            batch_requested=1
            read_batch "$2" || fail "cannot read batch file: $2"
            ;;
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

  add_url "$1"
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

if [ -z "$urls" ]; then
  [ "$batch_requested" -eq 0 ] || fail 'no video URLs found in batch files.'
  printf 'YouTube URL: '
  IFS= read -r url || [ -n "$url" ] || fail 'a video URL is required.'
  add_url "$url"
fi

if [ "$list_resolutions" -eq 1 ]; then
  set -- "$@" --list-formats
else
  formats='bestvideo*+bestaudio/best'
  if [ -n "$resolution" ]; then
    formats="bestvideo*[height=$resolution]+bestaudio/best[height=$resolution]"
  fi

  set -- "$@" --no-overwrites \
    --format-sort-force -S res \
    -f "$formats" \
    --paths "home:$destination" \
    --merge-output-format mkv \
    -o '%(title)s [%(id)s].%(ext)s'

  if [ "$keep_video" -eq 1 ]; then
    set -- "$@" --keep-video
  fi
fi

exec yt-dlp "$@" --no-playlist --batch-file /dev/stdin <<EOF
$urls
EOF
