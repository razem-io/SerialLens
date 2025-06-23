#!/bin/bash

# Serial Lens Release Script
# Creates a dated release with GitHub integration and DMG packaging

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BUILD_DIR="$PROJECT_ROOT/build/release"
RELEASES_DIR="$PROJECT_ROOT/releases"

# Ensure we're in the project root
cd "$PROJECT_ROOT"

echo -e "${BLUE}🚀 Serial Lens Release Builder${NC}"
echo -e "${BLUE}================================${NC}"

# Generate date-based version
DATE_VERSION=$(date +"%Y.%m.%d")
BUILD_NUMBER=$(date +"%H%M")
FULL_VERSION="$DATE_VERSION-$BUILD_NUMBER"

echo -e "${YELLOW}📅 Version: ${FULL_VERSION}${NC}"

# Check if gh CLI is available
if ! command -v gh &> /dev/null; then
    echo -e "${RED}❌ GitHub CLI (gh) is required but not installed.${NC}"
    echo -e "${YELLOW}   Install it with: ${NC}brew install gh"
    exit 1
fi

# Check if we're in a git repository and logged into GitHub
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}❌ This is not a git repository${NC}"
    exit 1
fi

if ! gh auth status > /dev/null 2>&1; then
    echo -e "${RED}❌ Not logged into GitHub CLI${NC}"
    echo -e "${YELLOW}   Run: ${NC}gh auth login"
    exit 1
fi

# Clean previous builds
echo -e "${YELLOW}🧹 Cleaning previous builds...${NC}"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
mkdir -p "$RELEASES_DIR"

# Update pubspec.yaml with new version
echo -e "${YELLOW}📝 Updating version in pubspec.yaml...${NC}"
sed -i '' "s/^version: .*/version: $DATE_VERSION+$BUILD_NUMBER/" pubspec.yaml

# Build the Flutter app
echo -e "${YELLOW}🔨 Building Flutter macOS app...${NC}"
flutter clean
flutter pub get
flutter build macos --release --build-name="$DATE_VERSION" --build-number="$BUILD_NUMBER"

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Flutter build failed${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Flutter build successful${NC}"

# Path to the built app
APP_PATH="$PROJECT_ROOT/build/macos/Build/Products/Release/Serial Lens.app"
APP_NAME="Serial Lens"

if [ ! -d "$APP_PATH" ]; then
    echo -e "${RED}❌ Built app not found at: $APP_PATH${NC}"
    exit 1
fi

# Create release directory for this version
RELEASE_DIR="$RELEASES_DIR/$FULL_VERSION"
mkdir -p "$RELEASE_DIR"

echo -e "${YELLOW}📦 Creating distribution packages...${NC}"

# Copy the .app bundle
cp -R "$APP_PATH" "$RELEASE_DIR/"

# Create a simple ZIP archive
echo -e "${YELLOW}📦 Creating ZIP archive...${NC}"
cd "$RELEASES_DIR"
ZIP_NAME="Serial-Lens-$FULL_VERSION-macOS.zip"
zip -r "$ZIP_NAME" "$FULL_VERSION/" -x "*.DS_Store"

# Create DMG if create-dmg is available
DMG_NAME="Serial-Lens-$FULL_VERSION-macOS.dmg"
if command -v create-dmg &> /dev/null; then
    echo -e "${YELLOW}💿 Creating DMG installer...${NC}"
    
    # Remove existing DMG if it exists
    rm -f "$DMG_NAME"
    
    create-dmg \
        --volname "Serial Lens $DATE_VERSION" \
        --volicon "$PROJECT_ROOT/macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_512.png" \
        --window-pos 200 120 \
        --window-size 800 400 \
        --icon-size 100 \
        --icon "$APP_NAME" 200 190 \
        --hide-extension "$APP_NAME" \
        --app-drop-link 600 185 \
        --hdiutil-verbose \
        "$DMG_NAME" \
        "$FULL_VERSION/"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ DMG created successfully${NC}"
    else
        echo -e "${YELLOW}⚠️  DMG creation failed, but ZIP is available${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  create-dmg not found, skipping DMG creation${NC}"
    echo -e "${YELLOW}   Install it with: ${NC}brew install create-dmg"
fi

cd "$PROJECT_ROOT"

# Get app size info
APP_SIZE=$(du -sh "$APP_PATH" | cut -f1)
ZIP_SIZE=$(du -sh "$RELEASES_DIR/$ZIP_NAME" | cut -f1)

# Create release notes
RELEASE_NOTES="$RELEASE_DIR/RELEASE_NOTES.md"
cat > "$RELEASE_NOTES" << EOF
# Serial Lens $DATE_VERSION

**Release Date:** $(date +"%B %d, %Y")  
**Build:** $BUILD_NUMBER  
**Platform:** macOS (Universal Binary)

## 📦 Package Information
- **App Size:** $APP_SIZE
- **ZIP Size:** $ZIP_SIZE
- **Requirements:** macOS 10.13 or later

## 🔧 Installation
1. Download the DMG or ZIP file
2. If using DMG: Mount and drag Serial Lens to Applications folder
3. If using ZIP: Extract and move Serial Lens.app to Applications folder
4. Launch Serial Lens from Applications or Spotlight

## ⚠️ First Launch
On first launch, you may see a security warning since the app is not notarized. To run:
1. Right-click on Serial Lens.app
2. Select "Open" from the context menu
3. Click "Open" in the security dialog

## 📋 Features
- Multi-device support for Even Realities G1 smart AR glasses
- Real-time battery monitoring (case, left glass, right glass)
- Charging status and current monitoring
- Temperature readings (NFC ICs and battery)
- Hardware status indicators (USB, lid position, NFC states)
- Auto-reconnection functionality
- Cross-platform architecture (macOS optimized)

## 🔗 Serial Communication
- **Supported Devices:** Even Realities G1 smart glasses
- **Connection:** USB-C via CH34x serial interface
- **Baud Rate:** 115200
- **Ports:** /dev/tty.usbserial-* (preferred) or /dev/cu.usbserial-*

## 🏗️ Build Information
- **Flutter Version:** $(flutter --version | head -n1)
- **Build Type:** Release
- **Architectures:** arm64, x86_64 (Universal Binary)
- **Dependencies:** flutter_libserialport, provider, fl_chart

## 🐛 Known Issues
- First launch requires manual security approval
- Some G1 hardware variants may need different port configurations
- Occasional connection drops during rapid data updates

## 📞 Support
Report issues at: https://github.com/yourusername/SerialLens/issues

---
🤖 *This release was generated automatically by the Serial Lens build system.*
EOF

# Commit the version change
echo -e "${YELLOW}📝 Committing version update...${NC}"
git add pubspec.yaml
git commit -m "Release $FULL_VERSION

🚀 Generated with Serial Lens Release Builder

Co-Authored-By: Claude <noreply@anthropic.com>"

# Create and push tag
TAG_NAME="v$FULL_VERSION"
echo -e "${YELLOW}🏷️  Creating tag: $TAG_NAME${NC}"
git tag -a "$TAG_NAME" -m "Release $FULL_VERSION"
git push origin main
git push origin "$TAG_NAME"

# Create GitHub release
echo -e "${YELLOW}🐙 Creating GitHub release...${NC}"

# Prepare assets
ASSETS=()
ASSETS+=("$RELEASES_DIR/$ZIP_NAME")
if [ -f "$RELEASES_DIR/$DMG_NAME" ]; then
    ASSETS+=("$RELEASES_DIR/$DMG_NAME")
fi

# Create the release
gh release create "$TAG_NAME" \
    --title "Serial Lens $DATE_VERSION" \
    --notes-file "$RELEASE_NOTES" \
    --draft=false \
    --prerelease=false \
    "${ASSETS[@]}"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ GitHub release created successfully!${NC}"
    RELEASE_URL=$(gh release view "$TAG_NAME" --json url -q .url)
    echo -e "${BLUE}🔗 Release URL: $RELEASE_URL${NC}"
else
    echo -e "${RED}❌ Failed to create GitHub release${NC}"
    exit 1
fi

# Summary
echo -e "\n${GREEN}🎉 Release Complete!${NC}"
echo -e "${GREEN}==================${NC}"
echo -e "${BLUE}Version:${NC} $FULL_VERSION"
echo -e "${BLUE}Tag:${NC} $TAG_NAME"
echo -e "${BLUE}App Size:${NC} $APP_SIZE"
echo -e "${BLUE}ZIP:${NC} $ZIP_SIZE"
if [ -f "$RELEASES_DIR/$DMG_NAME" ]; then
    DMG_SIZE=$(du -sh "$RELEASES_DIR/$DMG_NAME" | cut -f1)
    echo -e "${BLUE}DMG:${NC} $DMG_SIZE"
fi
echo -e "${BLUE}Local Path:${NC} $RELEASE_DIR"
echo -e "${BLUE}GitHub:${NC} $RELEASE_URL"

echo -e "\n${YELLOW}📋 Next Steps:${NC}"
echo -e "  • Test the release packages"
echo -e "  • Update documentation if needed"
echo -e "  • Announce the release"
echo -e "  • Consider app notarization for future releases"

exit 0