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

# Target address for faucet claims
TARGET_ADDRESS = "0xca1069955bD83ccD5371182d0276FeC855f7C97F"

# Async main claim loop
async def claim_loop():
    """Main faucet claiming loop with 24h rolling window and 1000 claim limit."""
    print(f"Starting Base Sepolia ETH faucet claimer for {TARGET_ADDRESS}")
    
    # Check environment variables
    if not os.getenv("CDP_API_KEY_ID") or not os.getenv("CDP_API_KEY_SECRET"):
        print("Error: CDP_API_KEY_ID and CDP_API_KEY_SECRET environment variables required")
        sys.exit(1)
    
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
                await asyncio.sleep(3600)  # Sleep for 1 hour
                continue
            
            # Request faucet
            print(f"[{now}] Attempting faucet claim (total claims in 24h: {len(claims)})...")
            
            # Use CDP client to request faucet funds
            async with CdpClient() as cdp:
                faucet_response = await cdp.evm.request_faucet(
                    address=TARGET_ADDRESS,
                    network="base-sepolia",
                    token="eth"
                )
            
            # Record successful claim
            claims.append(now)
            tx_link = faucet_response.get('transaction_link', 'N/A')
            print(f"[{now}] Faucet claim successful! Transaction: {tx_link}")
            
            # Sleep for 90 seconds before next attempt
            print(f"[{now}] Sleeping for 90 seconds...")
            await asyncio.sleep(90)
            
        except Exception as e:
            # On exception, sleep for 5 minutes
            error_time = datetime.datetime.now()
            print(f"[{error_time}] Error occurred: {str(e)}")
            print(f"[{error_time}] Sleeping for 5 minutes...")
            await asyncio.sleep(300)  # Sleep for 5 minutes

def main():
    """Entry point that runs the async claim loop."""
    asyncio.run(claim_loop())

if __name__ == "__main__":
    main()
