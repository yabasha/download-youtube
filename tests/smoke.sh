#!/bin/sh
set -eu

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

[ "$#" -le 1 ] || fail "Usage: ${0##*/} [YOUTUBE_URL]"
url=${1-https://youtu.be/jNQXAC9IVRw}

for tool in yt-dlp ffmpeg ffprobe; do
  command -v "$tool" >/dev/null 2>&1 || fail "$tool is required on PATH."
done

repo_dir=$(CDPATH= cd "$(dirname "$0")/.." && pwd)
scratch=$(mktemp -d "${TMPDIR:-/tmp}/download-youtube-smoke.XXXXXXXX")
trap 'rm -rf -- "$scratch"' 0
trap 'exit 1' HUP INT TERM

destination='download output'
printf 'Downloading sample: %s\n' "$url"
if ! (
  cd "$scratch" && "$repo_dir/download-youtube.sh" -d "$destination" -- "$url"
); then
  fail 'The downloader returned an error.'
fi

output_dir=$scratch/$destination
result=
for file in "$output_dir"/* "$output_dir"/.[!.]* "$output_dir"/..?*; do
  [ -f "$file" ] || continue
  [ -z "$result" ] || fail 'Expected one completed file in the destination.'
  result=$file
done
[ -n "$result" ] && [ -s "$result" ] || fail 'No download found in the destination.'

video=$(ffprobe -v error -select_streams V:0 -show_entries stream=codec_type -of csv=p=0 "$result") ||
  fail 'Could not read the downloaded media.'
audio=$(ffprobe -v error -select_streams a:0 -show_entries stream=codec_type -of csv=p=0 "$result") ||
  fail 'Could not read the downloaded media.'
[ "$video" = video ] && [ "$audio" = audio ] || fail 'Expected both video and audio.'

printf 'PASS: %s contains video and audio.\n' "${result##*/}"
