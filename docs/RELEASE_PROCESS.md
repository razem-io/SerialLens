# Release Process

This document describes how to create releases for Serial Lens.

## Quick Start

Simply run the release script from the project root:

```bash
./release.sh
```

## What the Release Script Does

1. **Version Generation**: Creates a date-based version (YYYY.MM.DD-HHMM)
2. **Build**: Compiles the Flutter macOS app in release mode
3. **Packaging**: Creates both ZIP and DMG distributions (if `create-dmg` is available)
4. **Git Operations**: Commits version changes, creates and pushes tags
5. **GitHub Release**: Creates a GitHub release with assets and detailed notes

## Prerequisites

### Required Tools
- **Flutter SDK**: For building the app
- **Git**: Version control and tagging
- **GitHub CLI (gh)**: For creating GitHub releases
  ```bash
  brew install gh
  gh auth login
  ```

### Optional Tools
- **create-dmg**: For creating professional DMG installers
  ```bash
  brew install create-dmg
  ```

## Version Format

Versions follow the pattern: `YYYY.MM.DD-HHMM`

Examples:
- `2025.06.23-1430` (June 23, 2025 at 2:30 PM)
- `2025.12.31-0900` (December 31, 2025 at 9:00 AM)

This format provides:
- **Chronological ordering**: Newer versions are always higher
- **Human readability**: Easy to understand when a release was made
- **Uniqueness**: Multiple releases per day are supported
- **Semantic meaning**: Date indicates feature freeze point

## Build Outputs

The script creates several artifacts:

### 1. Application Bundle
- **Path**: `releases/YYYY.MM.DD-HHMM/Serial Lens.app`
- **Format**: Standard macOS application bundle
- **Size**: ~50MB (includes all dependencies)

### 2. ZIP Archive
- **Path**: `releases/Serial-Lens-YYYY.MM.DD-HHMM-macOS.zip`
- **Contents**: The .app bundle compressed
- **Use**: Easy distribution, GitHub release asset

### 3. DMG Installer (Optional)
- **Path**: `releases/Serial-Lens-YYYY.MM.DD-HHMM-macOS.dmg`
- **Features**: Drag-to-Applications, custom background, icon positioning
- **Requirements**: `create-dmg` tool must be installed

### 4. Release Notes
- **Path**: `releases/YYYY.MM.DD-HHMM/RELEASE_NOTES.md`
- **Contents**: Detailed release information, installation instructions, features

## Manual Release Steps

If you need to create a release manually:

1. **Update Version**:
   ```bash
   # Edit pubspec.yaml
   version: 2025.06.23+1430
   ```

2. **Build**:
   ```bash
   flutter clean
   flutter pub get
   flutter build macos --release --build-name="2025.06.23" --build-number="1430"
   ```

3. **Package**:
   ```bash
   # Create directories
   mkdir -p releases/2025.06.23-1430
   
   # Copy app
   cp -R "build/macos/Build/Products/Release/Serial Lens.app" releases/2025.06.23-1430/
   
   # Create ZIP
   cd releases
   zip -r "Serial-Lens-2025.06.23-1430-macOS.zip" "2025.06.23-1430/"
   ```

4. **Git Operations**:
   ```bash
   git add pubspec.yaml
   git commit -m "Release 2025.06.23-1430"
   git tag -a "v2025.06.23-1430" -m "Release 2025.06.23-1430"
   git push origin main
   git push origin "v2025.06.23-1430"
   ```

5. **GitHub Release**:
   ```bash
   gh release create "v2025.06.23-1430" \
     --title "Serial Lens 2025.06.23" \
     --notes-file "releases/2025.06.23-1430/RELEASE_NOTES.md" \
     "releases/Serial-Lens-2025.06.23-1430-macOS.zip"
   ```

## Distribution

### GitHub Releases
All releases are published to GitHub Releases with:
- Source code (automatic)
- ZIP archive
- DMG installer (if available)
- Detailed release notes

### Direct Distribution
Users can:
1. Download from GitHub Releases
2. Install via DMG (recommended)
3. Extract ZIP and move .app to Applications

## Security Considerations

### Code Signing
Currently, releases are **not code signed**. Users will see security warnings on first launch.

To run unsigned apps:
1. Right-click → "Open"
2. Click "Open" in security dialog

### Future Improvements
- [ ] Apple Developer ID signing
- [ ] App notarization
- [ ] Automated security scanning
- [ ] Dependency vulnerability checks

## Troubleshooting

### Common Issues

1. **Flutter build fails**:
   - Run `flutter doctor` to check setup
   - Ensure Xcode Command Line Tools are installed
   - Clear build cache: `flutter clean`

2. **GitHub CLI not authenticated**:
   ```bash
   gh auth login
   ```

3. **Git repository issues**:
   - Ensure you're in the project root
   - Check remote repository is configured
   - Verify you have push permissions

4. **DMG creation fails**:
   - Install create-dmg: `brew install create-dmg`
   - Check available disk space
   - Verify app bundle exists

### Build Requirements

- **macOS**: 10.15 or later (for building)
- **Xcode**: Latest version recommended
- **Flutter**: 3.0 or later
- **Disk Space**: ~500MB for build artifacts

## Release Strategy

### When to Release
- Major feature additions
- Critical bug fixes
- Security updates
- Dependency updates
- User-requested enhancements

### Version Planning
Since versions are date-based:
- Plan releases around development milestones
- Multiple releases per day are possible (different build numbers)
- No semantic versioning constraints
- Easy to correlate releases with development timeline

### Testing
Before releasing:
1. Test on clean macOS installation
2. Verify G1 device connectivity
3. Check all UI functionality
4. Test auto-reconnection features
5. Validate build on both Intel and Apple Silicon Macs

## Automation Opportunities

Future improvements could include:
- **CI/CD Pipeline**: Automated builds on push to main
- **Scheduled Releases**: Nightly or weekly builds
- **Test Integration**: Automated testing before release
- **Multi-platform**: Extend to Windows/Linux when ready
- **Release Approval**: Workflow for release approval process