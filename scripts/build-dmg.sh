#!/bin/zsh
set -euo pipefail

PROJECT_DIR="${0:A:h:h}"
APP_NAME="QuickKey"
APP_DIR="$PROJECT_DIR/dist/$APP_NAME.app"
DMG_PATH="$PROJECT_DIR/dist/$APP_NAME-macOS.dmg"
STAGING_DIR="$(mktemp -d "${TMPDIR:-/tmp}/QuickKey-dmg.XXXXXX")"

cleanup() {
    rm -rf "$STAGING_DIR"
}
trap cleanup EXIT

if [[ ! -d "$APP_DIR" ]]; then
    echo "Missing $APP_DIR. Run scripts/build-app.sh first." >&2
    exit 1
fi

ditto "$APP_DIR" "$STAGING_DIR/$APP_NAME.app"
ln -s /Applications "$STAGING_DIR/Applications"

hdiutil create \
    -volname "$APP_NAME" \
    -srcfolder "$STAGING_DIR" \
    -ov \
    -format UDZO \
    "$DMG_PATH"
hdiutil verify "$DMG_PATH"
echo "$DMG_PATH"
