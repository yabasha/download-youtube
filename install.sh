#!/bin/sh

fail() {
  printf 'Error: %s\n' "$1" >&2
  exit 1
}

case "$0" in
  */*) source_file=${0%/*}/download-youtube.sh ;;
  *) source_file=./download-youtube.sh ;;
esac
[ -f "$source_file" ] || fail 'download-youtube.sh must be next to install.sh.'
[ -n "${HOME-}" ] || fail 'HOME is not set.'

bin_dir=$HOME/.local/bin
command_path=$bin_dir/download-youtube
alias_path=$bin_dir/yt

if [ -L "$command_path" ]; then
  fail "$command_path is already a symlink; move it before installing."
elif [ -e "$command_path" ]; then
  if [ ! -f "$command_path" ] || [ ! -x "$command_path" ] || ! cmp -s "$source_file" "$command_path"; then
    fail "$command_path already exists and differs from this installation; move it before installing."
  fi
fi

if [ -L "$alias_path" ]; then
  target=$(readlink "$alias_path") || fail "Cannot read $alias_path."
  case "$target" in
    download-youtube|"$command_path") ;;
    *) fail "$alias_path already points elsewhere; move it before installing." ;;
  esac
elif [ -e "$alias_path" ]; then
  fail "$alias_path already exists; move it before installing."
fi

set --
for tool in yt-dlp ffmpeg; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    set -- "$@" "$tool"
  fi
done

if [ "$#" -gt 0 ]; then
  command -v brew >/dev/null 2>&1 ||
    fail "Missing tools: $*. Install them manually or put Homebrew on PATH, then rerun the installer."
  printf 'Installing missing tools with Homebrew: %s\n' "$*"
  brew install "$@" || fail 'Homebrew installation failed. Resolve the error above and rerun the installer.'
  for tool do
    command -v "$tool" >/dev/null 2>&1 ||
      fail "$tool is still missing from PATH. Check your Homebrew setup and rerun the installer."
  done
fi

mkdir -p "$bin_dir" || fail "Cannot create $bin_dir."
if [ ! -e "$command_path" ]; then
  install -m 755 "$source_file" "$command_path" || fail "Cannot install $command_path."
fi
if [ ! -L "$alias_path" ]; then
  ln -s download-youtube "$alias_path" || fail "Cannot create $alias_path."
fi

printf 'Ready: %s and %s\n' "$command_path" "$alias_path"
case ":$PATH:" in
  *":$bin_dir:"*) ;;
  *) printf '%s\n' 'To use these commands in your shell: export PATH="$HOME/.local/bin:$PATH"' ;;
esac
