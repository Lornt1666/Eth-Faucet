# 🚨 IF YOU'RE SEEING PIP ERRORS - RUN THIS NOW

## The Commands That Fix Everything:

```bash
cd ~/Eth-Faucet          # Navigate to repository
git pull && sh setup-ish.sh
```

Copy those lines, paste in iSH, press Enter.

## What It Does

1. **git pull** - Downloads the fixed scripts
2. **sh setup-ish.sh** - Runs setup, which now:
   - Removes broken pip automatically
   - Installs fresh pip
   - Installs CDP SDK
   - Sets up the faucet claimer

## No More Errors

The latest setup script (commit 91dad07) handles broken pip automatically. You don't need to run fix-pip.sh separately anymore.

## After It Completes

You'll be prompted for:
- CDP_API_KEY_ID
- CDP_API_KEY_SECRET

Enter your Coinbase Developer Platform API credentials and the faucet claimer will start automatically.

## If It Still Fails

1. Make sure you ran `git pull` first
2. Try: `sh fix-pip.sh` then `sh setup-ish.sh`
3. Read FINAL_SOLUTION.md for more details

---

**Just run:**
```bash
cd ~/Eth-Faucet
git pull && sh setup-ish.sh
```
