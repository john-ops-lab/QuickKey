#!/bin/zsh
set -euo pipefail

PROJECT_DIR="${0:A:h:h}"
APP_NAME="QuickKey"
APP_VERSION="${QUICKKEY_VERSION:-1.0.2}"
BUNDLE_VERSION="${QUICKKEY_BUILD_NUMBER:-3}"
SCRATCH_DIR="${QUICKKEY_BUILD_DIR:-$PROJECT_DIR/.build}"
APP_DIR="$PROJECT_DIR/dist/$APP_NAME.app"
ICON_SOURCE="$PROJECT_DIR/Assets/AppIcon.png"
ICONSET_DIR="$SCRATCH_DIR/AppIcon.iconset"

cd "$PROJECT_DIR"
swift build -c release --scratch-path "$SCRATCH_DIR"
BUILD_DIR="$(swift build -c release --scratch-path "$SCRATCH_DIR" --show-bin-path)"

rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS" "$APP_DIR/Contents/Resources"
cp "$BUILD_DIR/$APP_NAME" "$APP_DIR/Contents/MacOS/$APP_NAME"
for resource_bundle in "$BUILD_DIR"/*.bundle(N); do
    # SwiftPM's generated bundle accessor resolves executable resources from
    # Bundle.main.bundleURL, which is the .app root for a manually assembled app.
    ditto "$resource_bundle" "$APP_DIR/${resource_bundle:t}"
done
cp "$SCRATCH_DIR/checkouts/KeyboardShortcuts/license" \
    "$APP_DIR/Contents/Resources/KeyboardShortcuts-LICENSE.txt"
cp "$PROJECT_DIR/LICENSE" "$APP_DIR/Contents/Resources/QuickKey-LICENSE.txt"

rm -rf "$ICONSET_DIR"
mkdir -p "$ICONSET_DIR"
sips -z 16 16 "$ICON_SOURCE" --out "$ICONSET_DIR/icon_16x16.png" >/dev/null
sips -z 32 32 "$ICON_SOURCE" --out "$ICONSET_DIR/icon_16x16@2x.png" >/dev/null
sips -z 32 32 "$ICON_SOURCE" --out "$ICONSET_DIR/icon_32x32.png" >/dev/null
sips -z 64 64 "$ICON_SOURCE" --out "$ICONSET_DIR/icon_32x32@2x.png" >/dev/null
sips -z 128 128 "$ICON_SOURCE" --out "$ICONSET_DIR/icon_128x128.png" >/dev/null
sips -z 256 256 "$ICON_SOURCE" --out "$ICONSET_DIR/icon_128x128@2x.png" >/dev/null
sips -z 256 256 "$ICON_SOURCE" --out "$ICONSET_DIR/icon_256x256.png" >/dev/null
sips -z 512 512 "$ICON_SOURCE" --out "$ICONSET_DIR/icon_256x256@2x.png" >/dev/null
sips -z 512 512 "$ICON_SOURCE" --out "$ICONSET_DIR/icon_512x512.png" >/dev/null
sips -z 1024 1024 "$ICON_SOURCE" --out "$ICONSET_DIR/icon_512x512@2x.png" >/dev/null
iconutil -c icns "$ICONSET_DIR" -o "$APP_DIR/Contents/Resources/AppIcon.icns"

cat > "$APP_DIR/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key><string>zh_CN</string>
    <key>CFBundleExecutable</key><string>QuickKey</string>
    <key>CFBundleIdentifier</key><string>com.local.QuickKey</string>
    <key>CFBundleInfoDictionaryVersion</key><string>6.0</string>
    <key>CFBundleName</key><string>QuickKey</string>
    <key>CFBundleDisplayName</key><string>QuickKey</string>
    <key>CFBundleIconFile</key><string>AppIcon</string>
    <key>CFBundlePackageType</key><string>APPL</string>
    <key>CFBundleShortVersionString</key><string>$APP_VERSION</string>
    <key>CFBundleVersion</key><string>$BUNDLE_VERSION</string>
    <key>LSMinimumSystemVersion</key><string>13.0</string>
    <key>NSHighResolutionCapable</key><true/>
</dict>
</plist>
PLIST

codesign --force --deep --sign - "$APP_DIR"
echo "$APP_DIR"
