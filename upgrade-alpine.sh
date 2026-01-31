#!/bin/sh
# Alpine Linux Upgrade Helper for iSH
# This script helps upgrade Alpine Linux to get Python 3.10+
# Use with caution - backs up important files first

set -e

echo "============================================"
echo "Alpine Linux Upgrade Helper for iSH"
echo "============================================"
echo ""
echo "This script will upgrade Alpine Linux to get Python 3.10+"
echo ""

# Check current Alpine version
if [ -f /etc/alpine-release ]; then
    CURRENT_VERSION=$(cat /etc/alpine-release)
    echo "Current Alpine version: $CURRENT_VERSION"
else
    echo "Warning: Cannot detect Alpine version"
    CURRENT_VERSION="unknown"
fi

# Check Python version
if command -v python3 >/dev/null 2>&1; then
    PYTHON_VERSION=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
    echo "Current Python version: $PYTHON_VERSION"
else
    echo "Python3 not installed yet"
    PYTHON_VERSION="none"
fi

echo ""
echo "Target: Alpine 3.19 (includes Python 3.11)"
echo ""

# Warning
echo "⚠️  WARNING ⚠️"
echo "────────────────────────────────────────"
echo "This upgrade will modify system files."
echo "iSH may become unstable during the upgrade."
echo ""
echo "Important files will be backed up, but:"
echo "- The upgrade cannot be easily reversed"
echo "- Some packages may break"
echo "- You may need to reinstall some software"
echo ""

# Ask for confirmation
printf "Do you want to continue? (y/yes or n/no): "
read -r CONFIRM

# Convert to lowercase for case-insensitive comparison
CONFIRM_LOWER=$(echo "$CONFIRM" | tr '[:upper:]' '[:lower:]')

if [ "$CONFIRM_LOWER" != "yes" ] && [ "$CONFIRM_LOWER" != "y" ]; then
    echo ""
    echo "Upgrade cancelled."
    echo ""
    echo "Alternative: Reinstall iSH with a newer Alpine version"
    echo "1. Open iSH app"
    echo "2. Go to Settings (gear icon)"
    echo "3. Tap 'Distribution'"
    echo "4. Select 'Alpine 3.19' or newer"
    echo "5. Confirm reinstallation"
    echo ""
    exit 0
fi

echo ""
echo "Starting upgrade process..."
echo ""

# Step 1: Backup
echo "[1/5] Creating backup..."
BACKUP_DIR="$HOME/alpine-upgrade-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Backup important files
if [ -f /etc/apk/repositories ]; then
    cp /etc/apk/repositories "$BACKUP_DIR/repositories.bak"
    echo "✓ Backed up /etc/apk/repositories"
fi

if [ -f /etc/alpine-release ]; then
    cp /etc/alpine-release "$BACKUP_DIR/alpine-release.bak"
    echo "✓ Backed up /etc/alpine-release"
fi

echo "✓ Backups saved to: $BACKUP_DIR"
echo ""

# Step 2: Update repositories
echo "[2/5] Updating repository URLs..."

# Backup and modify repositories
cp /etc/apk/repositories /etc/apk/repositories.old

# Replace version numbers with v3.19
sed -i 's/v[0-9]\+\.[0-9]\+/v3.19/g' /etc/apk/repositories

echo "✓ Updated repository URLs to v3.19"
cat /etc/apk/repositories
echo ""

# Step 3: Update package index
echo "[3/5] Updating package index..."
apk update || {
    echo ""
    echo "Error: Failed to update package index"
    echo "Restoring backup..."
    cp /etc/apk/repositories.old /etc/apk/repositories
    exit 1
}
echo "✓ Package index updated"
echo ""

# Step 4: Upgrade packages
echo "[4/5] Upgrading packages (this may take a few minutes)..."
echo "Please wait..."
apk upgrade --available || {
    echo ""
    echo "Error: Package upgrade failed"
    echo "Your system may be in an inconsistent state."
    echo "Check the error messages above."
    exit 1
}
echo "✓ Packages upgraded"
echo ""

# Step 5: Verify
echo "[5/5] Verifying upgrade..."

if [ -f /etc/alpine-release ]; then
    NEW_VERSION=$(cat /etc/alpine-release)
    echo "New Alpine version: $NEW_VERSION"
fi

if command -v python3 >/dev/null 2>&1; then
    NEW_PYTHON=$(python3 --version 2>&1)
    echo "New Python version: $NEW_PYTHON"
    
    # Check if Python 3.10+
    PYTHON_MAJOR=$(python3 -c 'import sys; print(sys.version_info[0])')
    PYTHON_MINOR=$(python3 -c 'import sys; print(sys.version_info[1])')
    
    if [ "$PYTHON_MAJOR" -ge 3 ] && [ "$PYTHON_MINOR" -ge 10 ]; then
        echo "✓ Python 3.10+ is now available!"
    else
        echo "⚠️  Python is still version $PYTHON_MAJOR.$PYTHON_MINOR"
        echo "You may need to install Python 3.10+ manually:"
        echo "  apk add python3"
    fi
fi

echo ""
echo "============================================"
echo "Upgrade Complete!"
echo "============================================"
echo ""
echo "Next steps:"
echo "1. Sync filesystem: sync"
echo "2. Close and reopen iSH app"
echo "3. Run the setup script: sh setup-ish.sh"
echo ""
echo "Backup location: $BACKUP_DIR"
echo ""
