# Eth-Faucet

Continuous Base Sepolia ETH faucet claimer using Coinbase Developer Platform (CDP) SDK.

Automatically claims Base Sepolia ETH from the [Coinbase CDP Faucet](https://portal.cdp.coinbase.com/products/faucet?projectId=c3060223-a072-4aa2-8dc3-e3879cebd293&token=ETH&network=base-sepolia&address=0xca1069955bD83ccD5371182d0276FeC855f7C97F) for address `0xca1069955bD83ccD5371182d0276FeC855f7C97F`.

## Features

- **24-hour rolling window**: Tracks claims within the last 24 hours
- **Claim limit**: Maximum 1000 claims per 24-hour period (up to 0.1 ETH)
- **Smart retry logic**: 
  - 90 seconds between successful claims
  - 5 minutes wait on errors
  - 1 hour wait when claim limit reached
- **GitHub Actions**: Automated claiming every 2 minutes
- **iSH support**: Can run as background process on Alpine iOS

## Setup

### Prerequisites

1. **CDP API Keys**: Get your API credentials from [Coinbase Developer Platform](https://portal.cdp.coinbase.com/)
2. **Python 3.x** installed

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

### Run locally

```bash
python3 claim.py
```

### Run on iSH (Alpine iOS)

```bash
nohup python3 claim.py &
```

This runs the script in the background and keeps it running even after closing the terminal.

### GitHub Actions (Automated)

The repository includes a GitHub Actions workflow that automatically runs the claimer every 2 minutes.

#### Setup GitHub Secrets

Add the following secrets to your repository (`Settings` → `Secrets and variables` → `Actions`):

- `CDP_API_KEY_ID`: Your CDP API Key ID
- `CDP_API_KEY_SECRET`: Your CDP API Key Secret

The workflow will automatically start running every 2 minutes once the secrets are configured.

## How It Works

1. **Initialize**: Connects to CDP using API credentials
2. **Loop**: 
   - Filters claims older than 24 hours
   - Checks if 1000 claim limit reached
   - Requests faucet funds if under limit
   - Records successful claim timestamp
   - Waits 90 seconds before next attempt
3. **Error Handling**: On failure, waits 5 minutes before retry

## Target Address

All faucet claims are sent to: `0xca1069955bD83ccD5371182d0276FeC855f7C97F`

## License

MIT
