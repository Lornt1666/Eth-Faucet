# Fix for "setup-ish.sh: No such file or directory" Error

## Problem
When users clone the repository with the standard command:
```bash
git clone https://github.com/Lornt1666/Eth-Faucet.git
cd Eth-Faucet
sh setup-ish.sh
```

They get the error:
```
sh: can't open 'setup-ish.sh': No such file or directory
```

## Root Cause
The repository has two branches:
1. **RegenExcalibur-Webpage** (default branch) - Owner's website (kept separate)
2. **copilot/implement-faucet-claims-script** - Faucet claimer implementation

When users clone without specifying a branch, they get the default branch which is the website, not the faucet claimer.

## Solution: Clone the Faucet Branch Directly

### For Users Who Want the Faucet Claimer

**Option A: Clone the faucet branch directly (Recommended)**
```bash
git clone -b copilot/implement-faucet-claims-script https://github.com/Lornt1666/Eth-Faucet.git
cd Eth-Faucet
sh setup-ish.sh
```

**Option B: If already cloned, switch to the faucet branch**
```bash
cd Eth-Faucet
git checkout copilot/implement-faucet-claims-script
sh setup-ish.sh
```

## Repository Structure

This repository contains two separate projects on different branches:

- **RegenExcalibur-Webpage** branch: Owner's website (default)
- **copilot/implement-faucet-claims-script** branch: Base Sepolia ETH faucet claimer

**They are intentionally kept separate and should not be mixed.**

## For the User Who Reported the Issue

Since you've already cloned the repository, just run:
```bash
cd Eth-Faucet
git checkout copilot/implement-faucet-claims-script
sh setup-ish.sh
```

This will switch you to the faucet claimer branch and then you can run the setup script successfully!
