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

# Check Python version before proceeding
echo "Checking Python version..."
if command -v python3 >/dev/null 2>&1; then
    PYTHON_VERSION=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
    PYTHON_MAJOR=$(python3 -c 'import sys; print(sys.version_info[0])')
    PYTHON_MINOR=$(python3 -c 'import sys; print(sys.version_info[1])')
    
    echo "Found Python $PYTHON_VERSION"
    
    if [ "$PYTHON_MAJOR" -lt 3 ] || [ "$PYTHON_MAJOR" -eq 3 -a "$PYTHON_MINOR" -lt 10 ]; then
        echo ""
        echo "=========================================="
        echo "ERROR: Python 3.10 or higher is required"
        echo "=========================================="
        echo ""
        echo "Your Python version: $PYTHON_VERSION"
        echo "Required: Python 3.10+"
        echo ""
        echo "The CDP SDK requires Python 3.10 or higher."
        echo "Alpine Linux 3.14 only has Python 3.9."
        echo ""
        echo "Solutions:"
        echo ""
        echo "1. Easy upgrade with helper script:"
        echo "   sh upgrade-alpine.sh"
        echo "   (Upgrades Alpine to 3.19 with Python 3.11)"
        echo ""
        echo "2. Reinstall iSH with newer Alpine:"
        echo "   Open iSH settings and select Alpine 3.16+"
        echo "   (Requires reinstalling iSH - backs up data first!)"
        echo ""
        echo "3. Alternative: Use GitHub Actions instead"
        echo "   Set up automated claiming via GitHub Actions"
        echo "   (See README for instructions)"
        echo ""
        exit 1
    fi
else
    echo "Python3 not found, will install..."
fi

# Step 1: Install required packages
echo ""
echo "[1/5] Installing required packages..."
apk add --no-cache python3 py3-pip git procps || {
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
echo "Upgrading pip to latest version..."

# Use --break-system-packages for Python 3.11+ (Alpine 3.19+)
# This is safe in iSH as it's an isolated environment
pip3 install --upgrade pip --break-system-packages 2>&1 | grep -v "Requirement already satisfied" || true

echo "Installing cdp-sdk..."
pip3 install -r requirements.txt --break-system-packages || {
    echo ""
    echo "Error: Failed to install Python dependencies"
    echo ""
    echo "Troubleshooting steps:"
    echo "1. Check internet connection"
    echo "2. Try manually: pip3 install --upgrade pip --break-system-packages"
    echo "3. Try manually: pip3 install cdp-sdk --break-system-packages"
    echo "4. If still failing, check pip version: pip3 --version"
    echo ""
    echo "Note: --break-system-packages is required for Python 3.11+"
    echo "This is safe in iSH as it's an isolated environment."
    echo ""
    exit 1
}

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
