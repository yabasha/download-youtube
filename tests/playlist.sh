#!/bin/sh
set -eu

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

repo_dir=$(CDPATH= cd "$(dirname "$0")/.." && pwd)
scratch=$(mktemp -d "${TMPDIR:-/tmp}/download-youtube-playlist.XXXXXXXX")
trap 'rm -rf -- "$scratch"' 0
trap 'exit 1' HUP INT TERM

cat > "$scratch/yt-dlp" <<'EOF'
#!/bin/sh
mode=download
playlist=default
for arg do
  case "$arg" in
    --list-formats) mode=format-listing ;;
    --no-playlist) playlist=single-video ;;
    --yes-playlist) playlist=playlist ;;
  esac
done
printf '%s %s\n' "$mode" "$playlist"
cat
EOF
printf '%s\n' '#!/bin/sh' 'exit 1' > "$scratch/ffmpeg"
chmod +x "$scratch/yt-dlp" "$scratch/ffmpeg"

url='https://www.youtube.com/watch?v=jNQXAC9IVRw&list=PL00000000000000000000000000000000'

check_mode() {
  mode=$1
  shift
  expected=$(printf '%s single-video\n%s\n' "$mode" "$url")
  actual=$(PATH="$scratch:$PATH" "$repo_dir/download-youtube.sh" "$@" "$url") ||
    fail "$mode command failed."

  if [ "$actual" != "$expected" ]; then
    printf 'Expected:\n%s\nActual:\n%s\n' "$expected" "$actual" >&2
    fail "$mode did not select the linked video."
  fi

  printf 'PASS: %s selects the linked video for a URL containing list=.\n' "$mode"
}

check_mode download
check_mode format-listing -F
