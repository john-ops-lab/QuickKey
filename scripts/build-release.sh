#!/bin/zsh
set -euo pipefail

PROJECT_DIR="${0:A:h:h}"
DIST_DIR="$PROJECT_DIR/dist"
APP_NAME="QuickKey"
ZIP_PATH="$DIST_DIR/$APP_NAME-macOS.zip"

"$PROJECT_DIR/scripts/build-app.sh"

mkdir -p "$DIST_DIR"
ditto -c -k --sequesterRsrc --keepParent \
    "$DIST_DIR/$APP_NAME.app" \
    "$ZIP_PATH"
"$PROJECT_DIR/scripts/build-dmg.sh"

shasum -a 256 "$ZIP_PATH" "$DIST_DIR/$APP_NAME-macOS.dmg"
