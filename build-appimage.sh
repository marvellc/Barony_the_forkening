#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD="$ROOT/cmake-build-debug"
APPDIR="$ROOT/Barony.AppDir"
TOOLS="$ROOT/.appimage-tools"
OUTPUT="$ROOT/Barony-x86_64.AppImage"

LINUXDEPLOY="$TOOLS/linuxdeploy-x86_64.AppImage"
APPIMAGETOOL="$TOOLS/appimagetool-x86_64.AppImage"

BINARY="$APPDIR/usr/lib/barony/barony.bin"
DATA_DIR="$APPDIR/usr/share/barony"

if [[ ! -x "$BUILD/barony" ]]; then
    echo "ERROR: $BUILD/barony was not produced"
    exit 1
fi

echo "==> Creating AppDir"

rm -rf "$APPDIR"

mkdir -p \
    "$APPDIR/usr/lib/barony" \
    "$DATA_DIR" \
    "$TOOLS"

cp "$BUILD/barony" "$BINARY"

echo "==> Copying Barony game data"

ASSET_DIRS=(
    books
    data
    fonts
    images
    items
    lang
    maps
    models
    music
    sound
)

for dir in "${ASSET_DIRS[@]}"; do
    if [[ -d "$ROOT/$dir" ]]; then
        echo "    $dir/"
        cp -a "$ROOT/$dir" "$DATA_DIR/"
    else
        echo "WARNING: missing asset directory: $dir"
    fi
done

for file in \
    gamecontrollerdb.txt \
    playernames-female.txt \
    playernames-male.txt
do
    if [[ -f "$ROOT/$file" ]]; then
        cp -a "$ROOT/$file" "$DATA_DIR/"
    fi
done

echo "==> Creating desktop entry"

cat > "$APPDIR/barony.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=Barony
Comment=First-person roguelike RPG
Exec=barony.bin
Icon=barony
Categories=Game;
Terminal=false
EOF

cat > "$APPDIR/barony.svg" <<'EOF'
<svg xmlns="http://www.w3.org/2000/svg"
     width="256"
     height="256"
     viewBox="0 0 256 256">
  <rect width="256" height="256" rx="28" fill="#222"/>
  <text x="128" y="177"
        text-anchor="middle"
        font-family="sans-serif"
        font-size="150"
        font-weight="bold"
        fill="#fff">B</text>
</svg>
EOF

echo "==> Getting AppImage tools"

if [[ ! -f "$LINUXDEPLOY" ]]; then
    curl -L \
        "https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage" \
        -o "$LINUXDEPLOY"
fi

if [[ ! -f "$APPIMAGETOOL" ]]; then
    curl -L \
        "https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage" \
        -o "$APPIMAGETOOL"
fi

chmod +x "$LINUXDEPLOY" "$APPIMAGETOOL"

echo "==> Bundling runtime libraries"

APPIMAGE_EXTRACT_AND_RUN=1 \
"$LINUXDEPLOY" \
    --appdir "$APPDIR" \
    --executable "$BINARY" \
    --desktop-file "$APPDIR/barony.desktop" \
    --icon-file "$APPDIR/barony.svg"

echo "==> Installing Barony-specific AppRun"

# linuxdeploy may create AppRun as a symlink.
# Remove it before creating our launcher.
rm -f "$APPDIR/AppRun"

cat > "$APPDIR/AppRun" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

export LD_LIBRARY_PATH="$HERE/usr/lib:$HERE/usr/lib64${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

# Barony expects its assets relative to the working directory.
cd "$HERE/usr/share/barony"

exec "$HERE/usr/lib/barony/barony.bin" "$@"
EOF

chmod +x "$APPDIR/AppRun"

echo "==> Verifying package"

file "$BINARY"
file "$APPDIR/AppRun"

if ! file "$BINARY" | grep -q "ELF"; then
    echo "ERROR: Barony binary is not an ELF executable"
    exit 1
fi

if [[ ! -x "$APPDIR/AppRun" ]]; then
    echo "ERROR: AppRun is not executable"
    exit 1
fi

echo "==> Checking bundled SDL libraries"

find "$APPDIR" \( -type f -o -type l \) |
    grep -E 'libSDL2|libphysfs' ||
    echo "WARNING: no SDL/PhysFS libraries found in AppDir"

echo "==> Creating AppImage"

rm -f "$OUTPUT"

ARCH=x86_64 \
APPIMAGE_EXTRACT_AND_RUN=1 \
"$APPIMAGETOOL" "$APPDIR" "$OUTPUT"

chmod +x "$OUTPUT"

echo
echo "========================================"
echo "Built:"
echo "$OUTPUT"
echo "========================================"
echo
echo "Test with:"
echo "  $OUTPUT --appimage-extract-and-run"