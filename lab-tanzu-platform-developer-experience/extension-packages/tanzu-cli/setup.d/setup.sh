#!/bin/bash

set -x
set -eo pipefail

PACKAGE_DIR=$(cd "$(dirname $BASH_SOURCE)/.."; pwd)

mkdir -p ~/bin
cp $PACKAGE_DIR/bin/tanzu ~/bin/

mkdir -p ~/.local/share
cp -r $PACKAGE_DIR/.local/share/tanzu-cli ~/.local/share/

mkdir -p ~/.config
cp -r $PACKAGE_DIR/.config/tanzu ~/.config/

mkdir -p ~/.cache
cp -r $PACKAGE_DIR/.cache/tanzu ~/.cache/