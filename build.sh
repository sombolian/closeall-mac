#!/bin/zsh
# Builds CloseAll.app and installs it to /Applications.
set -euo pipefail
cd "${0:A:h}"
rm -rf build && mkdir -p build/CloseAll.app/Contents/{MacOS,Resources} build/AppIcon.iconset

# Icon
swiftc -O MakeIcon.swift -o build/make-icon
build/make-icon build/icon-1024.png
for n in 16 32 128 256 512; do
  sips -z $n $n build/icon-1024.png --out build/AppIcon.iconset/icon_${n}x${n}.png >/dev/null
  sips -z $((n*2)) $((n*2)) build/icon-1024.png --out build/AppIcon.iconset/icon_${n}x${n}@2x.png >/dev/null
done
iconutil -c icns build/AppIcon.iconset -o build/CloseAll.app/Contents/Resources/AppIcon.icns

# App
swiftc -O -parse-as-library CloseAll.swift -o build/CloseAll.app/Contents/MacOS/CloseAll
cat > build/CloseAll.app/Contents/Info.plist <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key><string>CloseAll</string>
  <key>CFBundleDisplayName</key><string>CloseAll</string>
  <key>CFBundleIdentifier</key><string>local.closeall</string>
  <key>CFBundleExecutable</key><string>CloseAll</string>
  <key>CFBundleIconFile</key><string>AppIcon</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>2.0</string>
  <key>CFBundleVersion</key><string>2</string>
  <key>LSMinimumSystemVersion</key><string>14.0</string>
  <key>NSHighResolutionCapable</key><true/>
</dict>
</plist>
PLIST
codesign --force --sign - build/CloseAll.app

# Install
rm -rf /Applications/CloseAll.app
cp -R build/CloseAll.app /Applications/
touch /Applications/CloseAll.app
echo "Installed /Applications/CloseAll.app"
