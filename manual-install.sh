#!/bin/bash
set -e

echo "Manual Universal Mosgarage Installation"
echo "=========================================="

# Check current directory
echo "Current directory: $(pwd)"

# Check if .mosgarage exists
if [[ -d ".mosgarage" ]]; then
    echo "Found existing .mosgarage directory"
    echo "Contents:"
    ls -la .mosgarage/
    echo ""
    read -p "Remove and reinstall? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf .mosgarage
        echo "Removed old .mosgarage"
    else
        echo "Keeping existing .mosgarage"
        exit 0
    fi
fi

# Download
echo ""
echo "Downloading universal-mosgarage..."
if curl -L https://github.com/mosgarage/universal-mosgarage/archive/main.tar.gz -o mosgarage.tar.gz; then
    echo "✓ Download successful"
else
    echo "✗ Download failed"
    exit 1
fi

# Check file size
size=$(stat -f%z mosgarage.tar.gz 2>/dev/null || stat -c%s mosgarage.tar.gz 2>/dev/null || echo 0)
echo "Downloaded file size: $size bytes"

# List contents
echo ""
echo "Archive contents:"
tar tzf mosgarage.tar.gz | head -20

# Extract
echo ""
echo "Extracting..."
if tar xzf mosgarage.tar.gz; then
    echo "✓ Extraction successful"
else
    echo "✗ Extraction failed"
    exit 1
fi

# Move .mosgarage to current directory
if [[ -d "universal-mosgarage-main/.mosgarage" ]]; then
    mv universal-mosgarage-main/.mosgarage .
    rm -rf universal-mosgarage-main
    echo "✓ Moved .mosgarage to current directory"
else
    echo "✗ .mosgarage not found in archive"
    exit 1
fi

# Clean up
rm mosgarage.tar.gz

# Verify installation
echo ""
echo "Verification:"
echo "-------------"

if [[ -f ".mosgarage/mosgarage.json" ]]; then
    echo "✓ mosgarage.json exists"
else
    echo "✗ mosgarage.json missing"
fi

if [[ -f ".mosgarage/Dockerfile" ]]; then
    echo "✓ Dockerfile exists"
    echo ""
    echo "Checking for LANGUAGE fix:"
    grep "LANGUAGE" .mosgarage/Dockerfile || echo "LANGUAGE not found"
else
    echo "✗ Dockerfile missing"
fi

if [[ -d ".mosgarage/scripts" ]]; then
    echo "✓ scripts directory exists"
    echo "  Scripts found:"
    ls .mosgarage/scripts/ | sed 's/^/    /'
else
    echo "✗ scripts directory missing"
fi

echo ""
echo "Installation complete!"
echo ""
echo "Next steps:"
echo "1. Open VS Code in this directory"
echo "2. Click 'Reopen in Container' when prompted"
echo "3. Or use Command Palette: 'Dev Containers: Reopen in Container'"