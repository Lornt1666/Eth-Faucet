#!/usr/bin/env python3
"""
Continuous Base Sepolia ETH faucet claimer using CDP SDK.
Maintains up to 0.1 ETH per rolling 24h (max 1000 claims).
Target address: 0xca1069955bD83ccD5371182d0276FeC855f7C97F
"""

import cdp
import time
import datetime
import os
import sys

# Target address for faucet claims
TARGET_ADDRESS = "0xca1069955bD83ccD5371182d0276FeC855f7C97F"

# Initialize CDP client
def init_cdp():
    """Initialize CDP client with API credentials from environment variables."""
    api_key_id = os.getenv("CDP_API_KEY_ID")
    api_key_secret = os.getenv("CDP_API_KEY_SECRET")
    
    if not api_key_id or not api_key_secret:
        print("Error: CDP_API_KEY_ID and CDP_API_KEY_SECRET environment variables required")
        sys.exit(1)
    
    # Configure CDP with API credentials
    cdp.Cdp.configure(api_key_id, api_key_secret)
    return cdp.Cdp()

# Main claim loop
def main():
    """Main faucet claiming loop with 24h rolling window and 1000 claim limit."""
    print(f"Starting Base Sepolia ETH faucet claimer for {TARGET_ADDRESS}")
    
    client = init_cdp()
    claims = []
    
    while True:
        try:
            # Get current time
            now = datetime.datetime.now()
            
            # Filter out claims older than 24 hours
            cutoff_time = now - datetime.timedelta(hours=24)
            claims = [claim_time for claim_time in claims if claim_time > cutoff_time]
            
            # Check if we've reached the 1000 claim limit in the last 24h
            if len(claims) >= 1000:
                print(f"[{now}] Reached 1000 claims in last 24h. Sleeping for 1 hour...")
                time.sleep(3600)  # Sleep for 1 hour
                continue
            
            # Request faucet
            print(f"[{now}] Attempting faucet claim (total claims in 24h: {len(claims)})...")
            
            # Request faucet for the target address on Base Sepolia network
            faucet_tx = client.request_faucet_funds(
                network_id="base-sepolia",
                address=TARGET_ADDRESS
            )
            
            # Record successful claim
            claims.append(now)
            print(f"[{now}] Faucet claim successful! Transaction: {faucet_tx}")
            
            # Sleep for 90 seconds before next attempt
            print(f"[{now}] Sleeping for 90 seconds...")
            time.sleep(90)
            
        except Exception as e:
            # On exception, sleep for 5 minutes
            error_time = datetime.datetime.now()
            print(f"[{error_time}] Error occurred: {str(e)}")
            print(f"[{error_time}] Sleeping for 5 minutes...")
            time.sleep(300)  # Sleep for 5 minutes

if __name__ == "__main__":
    main()
