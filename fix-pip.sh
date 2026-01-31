#!/bin/sh
set -e

echo "=================================="
echo "Pip Repair Script"
echo "=================================="
echo ""
echo "This script will fix broken pip after Alpine upgrade"
echo ""

# Check if running as root or with sudo
if [ "$(id -u)" -ne 0 ]; then
    echo "Note: This script needs to install packages."
    echo "If prompted for password, enter it."
    echo ""
fi

echo "[1/4] Checking current pip status..."
if pip3 --version 2>/dev/null; then
    echo "✓ pip is currently working"
    echo "Note: You can still run this to ensure clean installation"
else
    echo "✗ pip is broken (this is expected)"
fi
echo ""

echo "[2/4] Removing broken pip package..."
apk del py3-pip 2>/dev/null || echo "  (pip package not found or already removed)"
echo "✓ Removed"
echo ""

echo "[3/4] Installing clean pip package..."
apk add --no-cache py3-pip
echo "✓ Installed"
echo ""

echo "[4/4] Verifying pip works..."
if pip3 --version; then
    echo ""
    echo "=================================="
    echo "✓ SUCCESS! Pip is now fixed"
    echo "=================================="
    echo ""
    echo "Next step:"
    echo "  sh setup-ish.sh"
    echo ""
else
    echo ""
    echo "=================================="
    echo "✗ Error: Pip still not working"
    echo "=================================="
    echo ""
    echo "Please try:"
    echo "  1. Close and reopen iSH app"
    echo "  2. Run this script again"
    echo ""
    exit 1
fi
