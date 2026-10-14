#!/bin/zsh
# Builds a Release copy of Vokie, ad-hoc signs it, and packages it as dist/Vokie.dmg.
# For personal use: the app is not notarized or signed with a Developer ID.
set -euo pipefail

ROOT=${0:A:h:h}
BUILD="$ROOT/build"
DIST="$ROOT/dist"
STAGE="$BUILD/dmg"
export DEVELOPER_DIR=${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}

rm -rf "$BUILD" "$DIST"
mkdir -p "$STAGE" "$DIST"

xcodebuild -project "$ROOT/Vokie.xcodeproj" -scheme Vokie -configuration Release \
  -derivedDataPath "$BUILD/DerivedData" CODE_SIGN_IDENTITY=- build | grep -E 'error|BUILD' || true

APP="$BUILD/DerivedData/Build/Products/Release/Vokie.app"
[[ -d "$APP" ]] || { echo "Build failed: $APP not found" >&2; exit 1; }
codesign --verify --strict "$APP"

ditto "$APP" "$STAGE/Vokie.app"
ln -s /Applications "$STAGE/Applications"
hdiutil create -volname Vokie -srcfolder "$STAGE" -fs HFS+ -format UDZO -ov "$DIST/Vokie.dmg" >/dev/null

echo "Created $DIST/Vokie.dmg"
