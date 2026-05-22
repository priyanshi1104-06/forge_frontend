#!/usr/bin/env bash
set -euo pipefail

# Install Flutter SDK if not already present
FLUTTER_DIR="$HOME/flutter"
if [ ! -d "$FLUTTER_DIR" ]; then
  git clone --depth 1 -b stable https://github.com/flutter/flutter.git "$FLUTTER_DIR"
fi

export PATH="$FLUTTER_DIR/bin:$PATH"

# Enable web support and precache artifacts
flutter config --enable-web
flutter precache --web

# Ensure dependencies are installed
flutter pub get

# Build the web output
flutter build web --release
