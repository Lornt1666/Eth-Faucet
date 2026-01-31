# Quick Start Guide - Eth Faucet Claimer

## 🚨 Common Issue: "File Not Found" Error

If you see this error:
```
sh: can't open 'upgrade-alpine.sh': No such file or directory
```

**You're probably already in the correct directory!**

### ✅ Check Where You Are

Run this command:
```bash
pwd
ls -la
```

If you see `upgrade-alpine.sh` in the list, **you're in the right place!**

### 🎯 The Problem

Many users see a prompt like this:
```
localhost:~/Eth-Faucet/Eth-Faucet#
```

And think they need to run:
```bash
cd Eth-Faucet  # ❌ WRONG - you're already here!
```

**You don't need to change directories - you're already in the repository!**

### ✨ The Solution

Just run the scripts directly:

```bash
# If you see ~/Eth-Faucet/Eth-Faucet in your prompt:
# You're already in the right place!

# Check your Python version (should show 3.9 on Alpine 3.14)
python3 --version

# If Python is 3.9, upgrade Alpine first:
sh upgrade-alpine.sh

# After upgrading and restarting iSH, run:
sh setup-ish.sh
```

## 📋 Step-by-Step Guide

### Step 1: Clone the Repository (First Time Only)

```bash
git clone -b copilot/implement-faucet-claims-script https://github.com/Lornt1666/Eth-Faucet.git
cd Eth-Faucet
```

After this, you'll be in the `Eth-Faucet` directory.

### Step 2: Check What's Here

```bash
ls
```

You should see:
- `upgrade-alpine.sh`
- `setup-ish.sh`
- `claim.py`
- `README.md`
- etc.

### Step 3: Check Your Python Version

```bash
python3 --version
```

- If it shows `Python 3.9.x` → You need to upgrade Alpine (go to Step 4)
- If it shows `Python 3.10.x` or higher → Skip to Step 5

### Step 4: Upgrade Alpine (If Needed)

```bash
sh upgrade-alpine.sh
```

Follow the prompts, type `yes` when asked.

After the upgrade completes:
```bash
sync
# Close iSH completely and reopen it
# Then navigate back:
cd Eth-Faucet
```

### Step 5: Run the Setup

```bash
sh setup-ish.sh
```

This will:
- Install dependencies
- Ask for your CDP API keys
- Start the faucet claimer

## 🔧 Troubleshooting

### "No such file or directory"

**Solution:** You're probably in the wrong directory OR trying to navigate when you're already there.

Check where you are:
```bash
pwd
```

Should show something like: `/root/Eth-Faucet` or `~/Eth-Faucet`

List files:
```bash
ls
```

Should show: `upgrade-alpine.sh`, `setup-ish.sh`, etc.

### "Already in Eth-Faucet/Eth-Faucet"

If your prompt shows `~/Eth-Faucet/Eth-Faucet`, you're in a nested structure. This is fine! Just run the scripts:

```bash
# Don't try to cd anywhere, just run:
sh upgrade-alpine.sh
# or
sh setup-ish.sh
```

### Wrong Branch

If you cloned without specifying the branch, you might be on the wrong branch:

```bash
git checkout copilot/implement-faucet-claims-script
```

## 🎓 Understanding the Directory Structure

When you clone the repository:

```
~ (your home directory)
└── Eth-Faucet (repository directory)
    ├── upgrade-alpine.sh
    ├── setup-ish.sh
    ├── claim.py
    └── README.md
```

After running `cd Eth-Faucet`, you're IN the repository where all the scripts are.

**Don't try to cd into Eth-Faucet again!**

## 📱 For iSH Users

Your prompt might look like:
- `localhost:~#` → You're in home directory, need to `cd Eth-Faucet`
- `localhost:~/Eth-Faucet#` → You're in the repository, ready to run scripts!
- `localhost:~/Eth-Faucet/Eth-Faucet#` → You're in the repository, ready to run scripts!

The important thing is checking if the scripts are there with `ls`.

## ✅ Quick Test

Run this to confirm you're in the right place:

```bash
ls upgrade-alpine.sh setup-ish.sh claim.py 2>/dev/null && echo "✓ All files found - you're in the right place!" || echo "✗ Files not found - check your location with 'pwd'"
```

## 🚀 Alternative: GitHub Actions

If you can't get iSH to work, use GitHub Actions instead:

1. Fork this repository on GitHub
2. Go to Settings → Secrets
3. Add `CDP_API_KEY_ID` and `CDP_API_KEY_SECRET`
4. Enable Actions
5. Done! It runs automatically every 2 minutes

No Python, no Alpine, no iSH needed!
