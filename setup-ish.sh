#!/bin/sh
# iSH (Alpine iOS) Setup Script for Base Sepolia ETH Faucet Claimer
# Compatible with iSH on iPhone/iPad (iOS 13+)
# Requires: Alpine Linux 3.16+ (for Python 3.10+)
# This script sets up and runs the faucet claimer on iSH

set -e

echo "=================================="
echo "Base Sepolia Faucet Claimer Setup"
echo "=================================="
echo ""

# Check if running on Alpine (iSH)
if ! command -v apk >/dev/null 2>&1; then
    echo "Warning: This script is designed for Alpine Linux (iSH)"
    echo "Continuing anyway..."
fi

# Check Alpine version BEFORE installing any packages
# This prevents downgrading pip/setuptools when old Python is installed
echo "Checking Alpine Linux version..."
if [ -f /etc/alpine-release ]; then
    ALPINE_VERSION=$(cat /etc/alpine-release)
    ALPINE_MAJOR=$(echo "$ALPINE_VERSION" | cut -d. -f1)
    ALPINE_MINOR=$(echo "$ALPINE_VERSION" | cut -d. -f2)
    
    echo "Found Alpine Linux $ALPINE_VERSION"
    
    # Check if Alpine is at least 3.16 (which has Python 3.10+)
    if [ "$ALPINE_MAJOR" -lt 3 ] || [ "$ALPINE_MAJOR" -eq 3 -a "$ALPINE_MINOR" -lt 16 ]; then
        echo ""
        echo "=========================================="
        echo "ERROR: Alpine 3.16 or higher is required"
        echo "=========================================="
        echo ""
        echo "Your Alpine version: $ALPINE_VERSION"
        echo "Required: Alpine 3.16+ (for Python 3.10+)"
        echo ""
        echo "Alpine $ALPINE_VERSION only has Python 3.9, but CDP SDK requires Python 3.10+."
        echo ""
        echo "⚠️  DO NOT install packages on old Alpine - it will downgrade pip!"
        echo ""
        echo "Solutions:"
        echo ""
        echo "1. RECOMMENDED: Upgrade Alpine with helper script:"
        echo "   git pull                  # Get latest files first"
        echo "   sh upgrade-alpine.sh      # Run the upgrade"
        echo "   (Upgrades Alpine to 3.19 with Python 3.11)"
        echo ""
        echo "2. Alternative: Reinstall iSH with newer Alpine:"
        echo "   Open iSH settings and select Alpine 3.16+"
        echo "   (Requires reinstalling iSH)"
        echo ""
        echo "3. Alternative: Use GitHub Actions instead:"
        echo "   Set up automated claiming via GitHub Actions"
        echo "   (See README for instructions)"
        echo ""
        exit 1
    fi
    
    echo "✓ Alpine version is compatible"
else
    echo "Warning: Cannot detect Alpine version (/etc/alpine-release not found)"
    echo "Proceeding anyway, but Python 3.10+ is required."
fi

# Check Python version if already installed
echo ""
echo "Checking Python version..."
if command -v python3 >/dev/null 2>&1; then
    PYTHON_VERSION=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
    PYTHON_MAJOR=$(python3 -c 'import sys; print(sys.version_info[0])')
    PYTHON_MINOR=$(python3 -c 'import sys; print(sys.version_info[1])')
    
    echo "Found Python $PYTHON_VERSION"
    
    if [ "$PYTHON_MAJOR" -lt 3 ] || [ "$PYTHON_MAJOR" -eq 3 -a "$PYTHON_MINOR" -lt 10 ]; then
        echo ""
        echo "ERROR: Python 3.10+ required, but found $PYTHON_VERSION"
        echo "This shouldn't happen on Alpine 3.16+. Try running: sh upgrade-alpine.sh"
        echo ""
        exit 1
    fi
    
    echo "✓ Python version is compatible"
else
    echo "Python3 not found, will install from repositories..."
fi

# Step 1: Install required packages
echo ""
echo "[1/5] Installing required packages..."

# Install py3-cryptography from Alpine to avoid Rust build issues on i386
# CDP SDK depends on cryptography, but building it from source requires Rust
# which doesn't work well on iSH (i386-unknown-linux-musl architecture)
apk add --no-cache python3 py3-pip git procps py3-cryptography || {
    echo "Note: If package installation fails, try running: apk update first"
}

# Verify Python version after installation
PYTHON_VERSION=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
PYTHON_MAJOR=$(python3 -c 'import sys; print(sys.version_info[0])')
PYTHON_MINOR=$(python3 -c 'import sys; print(sys.version_info[1])')

echo "Installed Python version: $PYTHON_VERSION"

if [ "$PYTHON_MAJOR" -lt 3 ] || [ "$PYTHON_MAJOR" -eq 3 -a "$PYTHON_MINOR" -lt 10 ]; then
    echo ""
    echo "=========================================="
    echo "ERROR: Python 3.10 or higher is required"
    echo "=========================================="
    echo ""
    echo "Your Alpine version installed Python $PYTHON_VERSION"
    echo "This is too old for the CDP SDK."
    echo ""
    echo "Run the upgrade helper script:"
    echo "  sh upgrade-alpine.sh"
    echo ""
    echo "Or reinstall iSH with Alpine 3.16+ from iSH settings."
    echo ""
    exit 1
fi

# Step 2: Install Python dependencies
echo ""
echo "[2/5] Installing Python dependencies..."

# First, check if pip is working
echo "Checking pip installation..."
if ! pip3 --version > /dev/null 2>&1; then
    echo "⚠️  pip appears to be broken. Reinstalling..."
    apk del py3-pip 2>/dev/null || true
    apk add --no-cache py3-pip
fi

echo "Using system pip (upgrading pip on iSH often causes issues)..."
pip3 --version

# SKIP pip upgrade - it often breaks on iSH
# The system pip (23.3.1) works fine for our needs
# Note: --break-system-packages flag is used for Python 3.11+ (Alpine 3.19+)
# This is safe in iSH as it's an isolated environment

echo "Installing cdp-sdk..."
if ! pip3 install -r requirements.txt --break-system-packages 2>&1; then
    echo "⚠️  Installation failed. Trying to repair pip..."
    
    # Reinstall pip from Alpine packages
    apk del py3-pip 2>/dev/null || true
    apk add --no-cache py3-pip
    
    # Try again
    pip3 install -r requirements.txt --break-system-packages || {
        echo ""
        echo "Error: Failed to install Python dependencies"
        echo ""
        echo "Troubleshooting steps:"
        echo "1. Check internet connection: ping 8.8.8.8"
        echo "2. Check pip works: pip3 --version"
        echo "3. Repair pip if needed: apk del py3-pip && apk add py3-pip"
        echo "4. Try manual install: pip3 install cdp-sdk --break-system-packages"
        echo "5. Check full error above for specific package issues"
        echo ""
        echo "Note: --break-system-packages is required for Python 3.11+"
        echo "This is safe in iSH as it's an isolated environment."
        echo ""
        exit 1
    }
fi

# Step 3: Configure environment variables
echo ""
echo "[3/5] Configuring environment variables..."
echo ""
echo "Please enter your CDP API credentials:"
echo "(Get them from: https://portal.cdp.coinbase.com/)"
echo ""

# Check if already configured
if [ -z "$CDP_API_KEY_ID" ]; then
    read -p "CDP API Key ID: " api_key_id
    export CDP_API_KEY_ID="$api_key_id"
else
    echo "CDP_API_KEY_ID already set: $CDP_API_KEY_ID"
fi

if [ -z "$CDP_API_KEY_SECRET" ]; then
    read -p "CDP API Key Secret: " api_key_secret
    export CDP_API_KEY_SECRET="$api_key_secret"
else
    echo "CDP_API_KEY_SECRET already set: [hidden]"
fi

# Create a persistent env file
echo ""
echo "[4/5] Creating environment configuration file..."
cat > .env.sh << EOF
#!/bin/sh
# CDP API Credentials
export CDP_API_KEY_ID="$CDP_API_KEY_ID"
export CDP_API_KEY_SECRET="$CDP_API_KEY_SECRET"
EOF

chmod +x .env.sh
echo "Environment variables saved to .env.sh"
echo "To reload them in a new session, run: source .env.sh"

# Step 5: Start the faucet claimer
echo ""
echo "[5/5] Starting faucet claimer in background..."
echo ""

# Source the env file and start
. ./.env.sh

# Check if already running
if ps aux | grep -v grep | grep "python3.*claim.py" > /dev/null 2>&1; then
    echo "⚠️  Faucet claimer is already running!"
    echo ""
    echo "To stop it, find the PID with:"
    echo "  ps aux | grep claim.py"
    echo "Then kill it with:"
    echo "  kill <PID>"
    echo ""
    echo "To view logs:"
    echo "  tail -f nohup.out"
else
    # Start in background
    nohup python3 claim.py > nohup.out 2>&1 &
    PID=$!
    echo "✓ Faucet claimer started in background (PID: $PID)"
    echo ""
    echo "Monitoring logs..."
    sleep 3
    echo ""
    tail -20 nohup.out
fi

echo ""
echo "=================================="
echo "Setup Complete!"
echo "=================================="
echo ""
echo "Useful Commands:"
echo "  View logs:        tail -f nohup.out"
echo "  Check status:     ps aux | grep claim.py"
echo "  Stop claimer:     kill <PID>  (find PID with ps aux | grep claim.py)"
echo "  Restart claimer:  source .env.sh && nohup python3 claim.py > nohup.out 2>&1 &"
echo ""
echo "Target Address: 0xca1069955bD83ccD5371182d0276FeC855f7C97F"
echo "Compatible with: iSH on iPhone/iPad (iOS 13+)"
echo ""
