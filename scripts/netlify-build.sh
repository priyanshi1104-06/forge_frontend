#!/usr/bin/env bash
set -euo pipefail

# Install Flutter SDK (only available in CI)
echo "Installing Flutter SDK..."
git clone https://github.com/flutter/flutter.git --depth 1 --branch stable /opt/flutter
export PATH="/opt/flutter/bin:/opt/flutter/bin/cache/dart-sdk/bin:$PATH"

# Verify Flutter installation
echo "Verifying Flutter installation..."
flutter doctor -v

# Get dependencies
echo "Getting Flutter dependencies..."
flutter pub get

# Build web release
echo "Building Flutter web release..."
flutter build web --release

echo "Build completed successfully!"
