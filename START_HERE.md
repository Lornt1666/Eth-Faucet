# 🚀 Quick Start - Run These Commands

If you're seeing this, you're ready to set up the Base Sepolia ETH faucet claimer on iSH!

## Step 1: Get Latest Files

```bash
git pull
```

This ensures you have all the latest scripts and documentation.

## Step 2: Run the Alpine Upgrade (If Needed)

If you're on Alpine 3.14 (check with `cat /etc/alpine-release`):

```bash
sh upgrade-alpine.sh
```

Type `y` or `yes` when prompted, then wait for it to complete.

After completion:
```bash
sync                    # Sync filesystem
# Close and reopen iSH app
cd ~/Eth-Faucet        # Navigate back
git pull                # Get latest files
```

## Step 3: Run the Setup Script

```bash
sh setup-ish.sh
```

This will:
- Install required packages
- Install Python dependencies (CDP SDK)
- Prompt you for API credentials
- Start the faucet claimer in the background

## Step 4: Verify It's Running

```bash
ps aux | grep python
```

You should see `python3 claim.py` running.

## View Logs

```bash
tail -f nohup.out
```

Press `Ctrl+C` to stop viewing logs (the claimer keeps running).

## Stop the Claimer

```bash
# Find the process ID
ps aux | grep "python3 claim.py"

# Kill it (replace PID with actual number)
kill PID
```

---

## Need Help?

- **Troubleshooting**: See [QUICK_START.md](QUICK_START.md)
- **After Upgrade**: See [NEXT_STEPS.md](NEXT_STEPS.md)
- **Full Documentation**: See [README.md](README.md)

## Using GitHub Actions Instead?

If you prefer automated claiming via GitHub Actions instead of iSH:
1. Fork this repository
2. Add secrets: `CDP_API_KEY_ID` and `CDP_API_KEY_SECRET`
3. Enable Actions in your fork
4. The workflow runs automatically every 2 minutes

See [README.md](README.md) for detailed GitHub Actions setup.
