#!/bin/sh
# iSH (Alpine iOS) Setup Script for Base Sepolia ETH Faucet Claimer
# Compatible with iSH on iPhone/iPad (iOS 13+)
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

# Step 1: Install required packages
echo "[1/5] Installing required packages..."
apk add --no-cache python3 py3-pip git procps || {
    echo "Note: If package installation fails, try running: apk update first"
}

# Step 2: Install Python dependencies
echo ""
echo "[2/5] Installing Python dependencies..."
echo "Upgrading pip to latest version..."
pip3 install --upgrade pip 2>&1 | grep -v "Requirement already satisfied" || true

echo "Installing cdp-sdk..."
pip3 install -r requirements.txt || {
    echo ""
    echo "Error: Failed to install Python dependencies"
    echo ""
    echo "Troubleshooting steps:"
    echo "1. Check internet connection"
    echo "2. Try manually: pip3 install --upgrade pip"
    echo "3. Try manually: pip3 install cdp-sdk"
    echo "4. If still failing, check pip version: pip3 --version"
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
