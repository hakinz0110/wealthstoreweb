#!/bin/bash
# Vercel install script for Flutter

# Check if Flutter is already installed
if command -v flutter >/dev/null 2>&1; then
  echo "Flutter found in system"
else
  echo "Installing Flutter..."
  git clone https://github.com/flutter/flutter.git -b stable --depth 1
fi

# Add Flutter to PATH
export PATH="$PWD/flutter/bin:$PATH"

# Save PATH for next command
echo "export PATH=\"$PWD/flutter/bin:\$PATH\"" > flutter_path.sh

# Run Flutter doctor and get dependencies
flutter doctor
flutter pub get
