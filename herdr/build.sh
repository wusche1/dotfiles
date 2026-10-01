#!/bin/bash
# ./build.sh        clone/checkout herdr at $base, apply herdr.patch, build, link to ~/.local/bin/herdr
# ./build.sh patch  regenerate herdr.patch from the clone's working tree
set -e
base=d11c0c34
src=~/Projects/cloned_repos/herdr
here="$(cd "$(dirname "$0")" && pwd)"

if [ "$1" = patch ]; then
    git -C "$src" diff "$base" > "$here/herdr.patch"
    exit
fi

[ -d "$src" ] || git clone https://github.com/herdrdev/herdr.git "$src"
cd "$src"
git fetch -q origin
git checkout -q -B patched "$base"
git apply "$here/herdr.patch"
cargo build --release
mkdir -p ~/.local/bin
ln -sf "$src/target/release/herdr" ~/.local/bin/herdr
