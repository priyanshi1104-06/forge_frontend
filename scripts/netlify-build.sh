#!/usr/bin/env bash
set -e

# Use the Netlify cache dir if available, otherwise use $HOME
FLUTTER_DIR="${NETLIFY_CACHE_DIR:-$HOME}/flutter"

if [ ! -d "$FLUTTER_DIR" ]; then
  echo "Installing Flutter SDK into $FLUTTER_DIR..."
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 "$FLUTTER_DIR"
else
  echo "Using existing Flutter at $FLUTTER_DIR"
  # Optionally update if you want:
  (cd "$FLUTTER_DIR" && git pull --ff-only)
fi

export PATH="$FLUTTER_DIR/bin:$PATH"

# Verify and prepare
echo "Verifying Flutter installation..."
flutter --version
flutter precache

# Get dependencies
echo "Getting Flutter dependencies..."
flutter pub get

# Build web release
echo "Building Flutter web release..."
flutter build web --release

echo "Build completed successfully!"
