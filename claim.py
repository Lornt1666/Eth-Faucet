#!/usr/bin/env python3
"""
Continuous Base Sepolia ETH faucet claimer using CDP SDK.
Maintains up to 0.1 ETH per rolling 24h (max 1000 claims).
Target address: 0xca1069955bD83ccD5371182d0276FeC855f7C97F
"""

import asyncio
from cdp import CdpClient
import time
import datetime
import os
import sys
import json

# Target address for faucet claims
TARGET_ADDRESS = "0xca1069955bD83ccD5371182d0276FeC855f7C97F"
CLAIMS_FILE = "claims_history.json"

def load_claims():
    """Load claim history from file."""
    if os.path.exists(CLAIMS_FILE):
        try:
            with open(CLAIMS_FILE, 'r') as f:
                data = json.load(f)
                # Convert ISO format strings back to timezone-aware datetime objects
                claims = []
                for ts in data:
                    dt = datetime.datetime.fromisoformat(ts)
                    # Ensure timezone-aware (add UTC if naive)
                    if dt.tzinfo is None:
                        dt = dt.replace(tzinfo=datetime.timezone.utc)
                    claims.append(dt)
                return claims
        except (json.JSONDecodeError, ValueError):
            return []
    return []

def save_claims(claims):
    """Save claim history to file."""
    # Convert datetime objects to ISO format strings
    data = [ts.isoformat() for ts in claims]
    with open(CLAIMS_FILE, 'w') as f:
        json.dump(data, f)

async def claim_once():
    """Perform a single faucet claim attempt."""
    # Check environment variables
    if not os.getenv("CDP_API_KEY_ID") or not os.getenv("CDP_API_KEY_SECRET"):
        print("Error: CDP_API_KEY_ID and CDP_API_KEY_SECRET environment variables required")
        sys.exit(1)
    
    # Load claim history
    claims = load_claims()
    
    # Get current time (timezone-aware)
    now = datetime.datetime.now(datetime.timezone.utc)
    
    # Filter out claims older than 24 hours
    cutoff_time = now - datetime.timedelta(hours=24)
    claims = [claim_time for claim_time in claims if claim_time > cutoff_time]
    
    # Check if we've reached the 1000 claim limit in the last 24h
    if len(claims) >= 1000:
        print(f"[{now}] Reached 1000 claims in last 24h. Skipping claim.")
        return False
    
    # Request faucet
    print(f"[{now}] Attempting faucet claim (total claims in 24h: {len(claims)})...")
    
    try:
        # Use CDP client to request faucet funds
        async with CdpClient() as cdp:
            faucet_response = await cdp.evm.request_faucet(
                address=TARGET_ADDRESS,
                network="base-sepolia",
                token="eth"
            )
        
        # Record successful claim
        claims.append(now)
        save_claims(claims)
        
        # Extract transaction link from response (handle different response formats)
        tx_link = 'N/A'
        if isinstance(faucet_response, dict):
            tx_link = faucet_response.get('transaction_link', 'N/A')
        elif hasattr(faucet_response, 'transaction_link'):
            tx_link = faucet_response.transaction_link
        
        print(f"[{now}] Faucet claim successful! Transaction: {tx_link}")
        return True
        
    except Exception as e:
        print(f"[{now}] Error occurred: {str(e)}")
        return False

async def claim_loop():
    """Main faucet claiming loop with 24h rolling window and 1000 claim limit."""
    print(f"Starting Base Sepolia ETH faucet claimer for {TARGET_ADDRESS}")
    
    while True:
        success = await claim_once()
        
        if success:
            # Sleep for 90 seconds before next attempt
            print(f"Sleeping for 90 seconds...")
            await asyncio.sleep(90)
        else:
            # Check if we hit the limit or had an error
            claims = load_claims()
            now = datetime.datetime.now(datetime.timezone.utc)
            cutoff_time = now - datetime.timedelta(hours=24)
            claims = [claim_time for claim_time in claims if claim_time > cutoff_time]
            
            if len(claims) >= 1000:
                # Hit claim limit, sleep for 1 hour
                print(f"Sleeping for 1 hour...")
                await asyncio.sleep(3600)
            else:
                # Had an error, sleep for 5 minutes
                print(f"Sleeping for 5 minutes...")
                await asyncio.sleep(300)

def main():
    """Entry point that runs based on mode."""
    mode = os.getenv("CLAIM_MODE", "continuous")
    
    if mode == "single":
        # Single claim mode for GitHub Actions
        asyncio.run(claim_once())
    else:
        # Continuous mode for iSH
        asyncio.run(claim_loop())

if __name__ == "__main__":
    main()
