#!/usr/bin/env bash
set -e

FLUTTER_HOME="$HOME/flutter"

if [ ! -d "$FLUTTER_HOME" ]; then
  echo "Installing Flutter SDK (stable)..."
  git clone https://github.com/flutter/flutter.git \
    --depth 1 \
    -b stable \
    "$FLUTTER_HOME"
fi

export PATH="$PATH:$FLUTTER_HOME/bin"

flutter --version
flutter config --no-analytics
flutter config --enable-web
flutter pub get
flutter build web --release
