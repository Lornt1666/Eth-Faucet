# Eth-Faucet

Continuous Base Sepolia ETH faucet claimer using Coinbase Developer Platform (CDP) SDK.

Automatically claims Base Sepolia ETH from the [Coinbase CDP Faucet](https://portal.cdp.coinbase.com/products/faucet?projectId=c3060223-a072-4aa2-8dc3-e3879cebd293&token=ETH&network=base-sepolia&address=0xca1069955bD83ccD5371182d0276FeC855f7C97F) for address `0xca1069955bD83ccD5371182d0276FeC855f7C97F`.

## Features

- **24-hour rolling window**: Tracks claims within the last 24 hours (persisted to file)
- **Claim limit**: Maximum 1000 claims per 24-hour period (up to 0.1 ETH)
- **Two operation modes**:
  - **Continuous mode**: For iSH (Alpine iOS) - runs indefinitely with smart retry logic
  - **Single mode**: For GitHub Actions - performs one claim attempt per run
- **Smart retry logic** (continuous mode):
  - 90 seconds between successful claims
  - 5 minutes wait on errors
  - 1 hour wait when claim limit reached
- **GitHub Actions**: Automated claiming every 2 minutes with cache persistence
- **Timezone-aware**: Uses UTC for consistent time tracking across environments

## Setup

### Prerequisites

1. **CDP API Keys**: Get your API credentials from [Coinbase Developer Platform](https://portal.cdp.coinbase.com/)
2. **Python 3.10 or higher** - The CDP SDK requires Python 3.10+
   - For iSH users: Requires Alpine Linux 3.16 or higher (which includes Python 3.10+)
   - Alpine 3.14 only has Python 3.9 and will NOT work

### Installation

```bash
# Clone the repository
git clone https://github.com/Lornt1666/Eth-Faucet.git
cd Eth-Faucet

# Install dependencies
pip install -r requirements.txt
```

### Configuration

Set environment variables with your CDP API credentials:

```bash
export CDP_API_KEY_ID="your_api_key_id"
export CDP_API_KEY_SECRET="your_api_key_secret"
```

## Usage

### Quick Start for iSH (Alpine iOS)

**Important: Requires Alpine Linux 3.16 or higher for Python 3.10+ support**

Compatible with iSH on iPhone/iPad running iOS 13 and later.

#### Check Your Alpine Version

Before proceeding, verify your Alpine version:
```bash
cat /etc/alpine-release
```

If you have Alpine 3.14 or older, you need to upgrade to 3.16+ first.

#### Upgrade Alpine in iSH (if needed)

If you're on Alpine 3.14 or older:

**Option 1: Use the Upgrade Helper Script (Easiest)**
```bash
# Clone the repository first
git clone https://github.com/Lornt1666/Eth-Faucet.git
cd Eth-Faucet

# Run the upgrade helper
sh upgrade-alpine.sh
```

The upgrade helper will:
- Check your current Alpine and Python versions
- Create backups of important files
- Update repository URLs to Alpine 3.19
- Upgrade all packages
- Verify Python 3.10+ is available

**Option 2: Reinstall with newer Alpine (Clean install)**
1. Open iSH settings
2. Tap "Distribution"
3. Select "Alpine 3.16" or newer
4. Confirm reinstallation (this will reset iSH)

**Option 3: Manual upgrade (Advanced)**
```bash
# Backup important data first!
# Edit repositories to use newer version
sed -i 's/v3.14/v3.19/g' /etc/apk/repositories
# Update and upgrade
apk update
apk upgrade --available
sync
# Reboot iSH
```

#### Installation

The easiest way to set up and run on iSH (Alpine 3.16+):

```bash
# 1. Clone the repository
git clone https://github.com/Lornt1666/Eth-Faucet.git
cd Eth-Faucet

# 2. Run the automated setup script
sh setup-ish.sh
```

The script will:
- Check Python version (must be 3.10+)
- Install required packages (python3, py3-pip, git, procps)
- Install Python dependencies
- Prompt for your CDP API credentials
- Save credentials to `.env.sh` for persistence
- Start the claimer in background mode
- Show you the logs

**Useful commands after setup:**
```bash
# View live logs
tail -f nohup.out

# Check if running
ps aux | grep claim.py

# Stop the claimer (replace <PID> with actual process ID)
kill <PID>

# Find the PID
ps aux | grep claim.py

# Restart the claimer
source .env.sh && nohup python3 claim.py > nohup.out 2>&1 &
```

### Run locally (continuous mode)

```bash
python3 claim.py
```

### Manual iSH Setup (Alternative)

If you prefer manual setup on iSH (requires Alpine 3.16+ for Python 3.10+):

```bash
# Check Alpine version
cat /etc/alpine-release

# Update package index (recommended on first run)
apk update

# Install packages (Alpine 3.16+ will install Python 3.10+)
apk add python3 py3-pip git procps

# Verify Python version (must be 3.10+)
python3 --version

# Upgrade pip (important for older iSH versions)
pip3 install --upgrade pip

# Install dependencies
pip3 install -r requirements.txt

# Set environment variables
export CDP_API_KEY_ID="your_api_key_id"
export CDP_API_KEY_SECRET="your_api_key_secret"

# Run in background
nohup python3 claim.py &

# View logs
tail -f nohup.out
```

This runs the script in the background and keeps it running even after closing the terminal. The script will continuously attempt claims with smart retry logic.

**Note:** iSH is compatible with all modern iOS versions (iOS 13+). The app works the same way across all iPhone and iPad models.

**Important:** If using Alpine 3.14 or older, you MUST upgrade to Alpine 3.16+ first. Alpine 3.14 only has Python 3.9, but CDP SDK requires Python 3.10 or higher.

**Troubleshooting:** If you encounter `ERROR: Could not find a version that satisfies the requirement cdp-sdk`, this means your Python version is too old. Check with `python3 --version` - it must be 3.10 or higher.

### Run single claim attempt

```bash
CLAIM_MODE=single python3 claim.py
```

This performs a single claim attempt and exits, which is ideal for scheduled tasks.

### GitHub Actions (Automated)

The repository includes a GitHub Actions workflow that automatically runs the claimer every 2 minutes in single-claim mode.

#### Setup GitHub Secrets

Add the following secrets to your repository (`Settings` → `Secrets and variables` → `Actions`):

- `CDP_API_KEY_ID`: Your CDP API Key ID
- `CDP_API_KEY_SECRET`: Your CDP API Key Secret

The workflow will automatically start running every 2 minutes once the secrets are configured. Claim history is persisted between runs using GitHub Actions cache.

## How It Works

### Continuous Mode (iSH)

1. **Initialize**: Connects to CDP using API credentials
2. **Loop**: 
   - Loads claim history from file
   - Filters claims older than 24 hours
   - Checks if 1000 claim limit reached
   - Requests faucet funds if under limit
   - Records successful claim timestamp to file
   - Waits 90 seconds before next attempt
3. **Error Handling**: On failure, waits 5 minutes before retry
4. **Limit Handling**: When limit reached, waits 1 hour before retry

### Single Mode (GitHub Actions)

1. **Initialize**: Connects to CDP using API credentials
2. **Execute**: 
   - Loads claim history from cache
   - Filters claims older than 24 hours
   - Checks if 1000 claim limit reached
   - Requests faucet funds if under limit
   - Records successful claim timestamp to cache
   - Exits (workflow will run again in 2 minutes)
3. **Error Handling**: Logs error and exits (workflow will retry in 2 minutes)

## Target Address

All faucet claims are sent to: `0xca1069955bD83ccD5371182d0276FeC855f7C97F`

## License

MIT
