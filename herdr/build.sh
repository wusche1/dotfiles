#!/bin/bash
# ./build.sh        clone/checkout herdr at $base, apply herdr.patch, build, link to ~/.local/bin/herdr
#                   also cross-builds the x86_64 Linux binary that `remote` copies to remote machines
#                   (needs: zig 0.16.0 exactly, brew install cargo-zigbuild, rustup target add x86_64-unknown-linux-gnu)
# ./build.sh patch  regenerate herdr.patch from the clone's working tree
set -e
base=ee5bfb50
src=~/Projects/cloned_repos/herdr
here="$(cd "$(dirname "$0")" && pwd)"
export ZIG=${ZIG:-/opt/homebrew/Cellar/zig/0.16.0_1/bin/zig}
export CARGO_ZIGBUILD_ZIG_PATH=$ZIG

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
cargo zigbuild --release --target x86_64-unknown-linux-gnu.2.31
mkdir -p ~/.local/bin
ln -sf "$src/target/release/herdr" ~/.local/bin/herdr
