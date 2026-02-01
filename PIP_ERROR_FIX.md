# Fix: Pip Resolver Error After Alpine Upgrade

## The Error You're Seeing

```
File "/usr/lib/python3.11/site-packages/pip/_internal/resolution/resolvelib/resolver.py", line 8, in <module>
```

This error occurs when pip is in a broken state after upgrading Alpine Linux from 3.14 to 3.19.

## Quick Fix (2 Steps)

### Step 1: Get the Latest Fix

```bash
cd ~/Eth-Faucet
git pull
```

This updates your scripts with the automatic pip repair mechanism.

### Step 2: Re-run Setup

```bash
sh setup-ish.sh
```

The updated setup script will:
- ✅ Detect that pip is broken
- ✅ Automatically reinstall py3-pip
- ✅ Continue with installation
- ✅ Handle any errors gracefully

## What Happened?

When you upgraded from Alpine 3.14 to 3.19:
1. Python was upgraded from 3.9 to 3.11
2. Pip package structure changed
3. Old pip files became incompatible
4. Pip's resolver module broke

## If Quick Fix Doesn't Work

### Manual Pip Reinstall

```bash
# Remove broken pip
apk del py3-pip

# Install fresh pip
apk add py3-pip

# Run setup again
sh setup-ish.sh
```

### Alternative: Clean Python Environment

```bash
# Remove all Python packages
apk del python3 py3-pip py3-cryptography

# Reinstall fresh
apk add python3 py3-pip py3-cryptography

# Run setup
sh setup-ish.sh
```

## How to Avoid This

After upgrading Alpine:
1. **Always run** `git pull` to get latest scripts
2. **Close and reopen** iSH app after upgrade
3. **Run sync** before closing: `sync`

## Still Having Issues?

Check these files for more help:
- `START_HERE.md` - Complete setup guide
- `PULL_FIRST.md` - Why you need to pull
- `QUICK_START.md` - General troubleshooting

Or use GitHub Actions instead (no iSH setup needed):
- See `README.md` section "GitHub Actions Setup"
