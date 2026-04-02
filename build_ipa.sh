#!/bin/bash
set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_NAME="EphemerisApp"
SCHEME="EphemerisApp"

echo "🔨 Building $PROJECT_NAME..."

# Clean
xcodebuild clean \
  -project "$PROJECT_DIR/$PROJECT_NAME.xcodeproj" \
  -scheme "$SCHEME" \
  -configuration Release

# Build
xcodebuild build \
  -project "$PROJECT_DIR/$PROJECT_NAME.xcodeproj" \
  -scheme "$SCHEME" \
  -configuration Release \
  -destination "generic/platform=iOS" \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO \
  DEVELOPMENT_TEAM=""

# Package IPA
echo "📦 Packaging IPA..."
BUILD_DIR="$PROJECT_DIR/build/Release-iphoneos"
PAYLOAD_DIR="$BUILD_DIR/Payload"

mkdir -p "$PAYLOAD_DIR"
cp -r "$BUILD_DIR/$PROJECT_NAME.app" "$PAYLOAD_DIR/"

cd "$BUILD_DIR"
zip -r "$PROJECT_DIR/$PROJECT_NAME.ipa" Payload/

echo "✅ Unsigned IPA created: $PROJECT_DIR/$PROJECT_NAME.ipa"
