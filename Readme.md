# Alex's NixOS Configuration

A flake-based NixOS configuration with integrated Home Manager for declarative system and user environment management.

## 📋 Table of Contents

- [Overview](#overview)
- [Repository Structure](#repository-structure)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [Rebuilding from GitHub](#rebuilding-from-github)
- [Updating](#updating)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

## 🎯 Overview

This configuration uses:
- **NixOS Unstable** - Latest packages and features
- **Home Manager** - Declarative user environment management
- **Flakes** - Modern, reproducible Nix configuration
- **Budgie Desktop** - Desktop environment
- **Custom Modules** - Espanso text expansion service

## 📁 Repository Structure

```
.
├── flake.nix                      # Main flake configuration
├── flake.lock                     # Lock file for reproducible builds
├── nixos/
│   ├── configuration.nix          # System-wide configuration
│   └── hardware-configuration.nix # Hardware-specific settings
└── home-manager/
    ├── home.nix                   # User environment configuration
    └── modules/
        └── espanso.nix            # Espanso service module
```

## ⚙️ Prerequisites

- A running NixOS installation (version 23.11 or later)
- Git installed
- Flakes enabled in your current NixOS configuration

## 🚀 Installation

### 1. Clone the Repository

```bash
# Clone to your preferred location
git clone https://github.com/drunkod/nixos-config.git ~/nixos-config
cd ~/nixos-config
```

### 2. Backup Current Configuration

```bash
sudo cp -r /etc/nixos /etc/nixos.backup
```

### 3. Copy Hardware Configuration

```bash
# Copy your current hardware configuration
sudo cp /etc/nixos/hardware-configuration.nix ~/nixos-config/nixos/
```

### 4. Review and Customize

Edit the configuration files to match your setup:

```bash
# Update hostname, username, timezone, etc.
nano nixos/configuration.nix
nano home-manager/home.nix
```

### 5. Apply Configuration

```bash
# Build and switch to the new configuration
sudo nixos-rebuild switch --flake ~/nixos-config#hp
```

## 💻 Usage

### Adding System Packages

Edit `nixos/configuration.nix`:

```nix
environment.systemPackages = with pkgs; [
  git
  vim
  htop  # Add new packages here
];
```

### Adding User Packages

Edit `home-manager/home.nix`:

```nix
home.packages = with pkgs; [
  firefox
  thunderbird
  # Add your user packages here
];
```

### Enabling Programs

Edit `home-manager/home.nix`:

```nix
programs = {
  home-manager.enable = true;
  git = {
    enable = true;
    userName = "Your Name";
    userEmail = "your.email@example.com";
  };
  # Add more programs
};
```

### Rebuilding the System

After making changes:

```bash
# System-wide changes (requires sudo)
sudo nixos-rebuild switch --flake ~/nixos-config#hp

# Home Manager only changes (faster, no sudo needed)
home-manager switch --flake ~/nixos-config#alex
```

### Useful Commands

```bash
# Test configuration without switching
sudo nixos-rebuild test --flake ~/nixos-config#hp

# Build configuration without activating
sudo nixos-rebuild build --flake ~/nixos-config#hp

# Check what would change
sudo nixos-rebuild dry-build --flake ~/nixos-config#hp

# Roll back to previous generation
sudo nixos-rebuild switch --rollback

# List all generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Clean old generations (keep last 5)
sudo nix-collect-garbage --delete-older-than 30d
```

## 🌐 Rebuilding from GitHub

You can rebuild your system directly from your GitHub repository without cloning it locally. This is useful for:
- Quick deployments on new machines
- Testing configurations
- Keeping systems in sync across multiple machines

### Basic Usage

```bash
# Rebuild from main branch
sudo nixos-rebuild switch --flake github:drunkod/nixos-config#hp

# Test configuration without switching
sudo nixos-rebuild test --flake github:drunkod/nixos-config#hp

# Dry run to see what would change
sudo nixos-rebuild dry-build --flake github:drunkod/nixos-config#hp
```

### Using Different Branches

```bash
# Rebuild from a specific branch
sudo nixos-rebuild switch --flake github:drunkod/nixos-config/dev#hp

# Rebuild from a feature branch
sudo nixos-rebuild switch --flake github:drunkod/nixos-config/feature-hyprland#hp
```

### Using Specific Commits

```bash
# Rebuild from a specific commit
sudo nixos-rebuild switch --flake github:drunkod/nixos-config/a1b2c3d4e5f6#hp

# Test a specific commit before switching
sudo nixos-rebuild test --flake github:drunkod/nixos-config/a1b2c3d4e5f6#hp
```

### Using Tags

```bash
# Rebuild from a tagged release
sudo nixos-rebuild switch --flake github:drunkod/nixos-config/v1.0.0#hp
```

### Private Repositories

For private repositories, you need to configure Git authentication:

```bash
# Using SSH (recommended)
sudo nixos-rebuild switch --flake git+ssh://git@github.com/drunkod/nixos-config#hp

# Using GitHub token
sudo nixos-rebuild switch --flake "github:drunkod/nixos-config?token=ghp_yourtoken"
```

### Setting Up SSH for Root

Since `nixos-rebuild` runs as root, configure SSH access:

```bash
# Copy your SSH keys to root
sudo mkdir -p /root/.ssh
sudo cp ~/.ssh/id_ed25519 /root/.ssh/
sudo cp ~/.ssh/id_ed25519.pub /root/.ssh/
sudo chmod 600 /root/.ssh/id_ed25519
sudo chmod 644 /root/.ssh/id_ed25519.pub

# Or generate new keys for root
sudo ssh-keygen -t ed25519 -C "root@hostname"
```

Add the public key to your GitHub account: Settings → SSH and GPG keys → New SSH key

### Initial Setup on New Machine

When setting up a new machine:

```bash
# 1. Ensure hardware configuration exists
sudo cp /etc/nixos/hardware-configuration.nix /tmp/

# 2. Test the configuration from GitHub
sudo nixos-rebuild test --flake github:drunkod/nixos-config#hp

# 3. If successful, switch to it
sudo nixos-rebuild switch --flake github:drunkod/nixos-config#hp

# 4. Clone locally for future edits
git clone git@github.com:drunkod/nixos-config.git ~/nixos-config
sudo cp /tmp/hardware-configuration.nix ~/nixos-config/nixos/
```

### Update from Remote

```bash
# Update and rebuild in one command
sudo nixos-rebuild switch --flake github:drunkod/nixos-config#hp --refresh

# Force refresh flake inputs
sudo nixos-rebuild switch --flake github:drunkod/nixos-config#hp --recreate-lock-file
```

### Workflow Example

```bash
# On your main machine
cd ~/nixos-config
# Make changes
nano nixos/configuration.nix
# Test locally
sudo nixos-rebuild test --flake .#hp
# Commit and push
git add .
git commit -m "Update: added new packages"
git push origin main

# On another machine (or same machine from GitHub)
sudo nixos-rebuild switch --flake github:drunkod/nixos-config#hp --refresh
```

### Using with Multiple Machines

Configure multiple hosts in `flake.nix`:

```nix
outputs = { self, nixpkgs, home-manager, ... }: {
  nixosConfigurations = {
    hp = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./nixos/hosts/hp/configuration.nix ];
    };
    
    laptop = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./nixos/hosts/laptop/configuration.nix ];
    };
    
    server = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./nixos/hosts/server/configuration.nix ];
    };
  };
};
```

Then rebuild each machine:

```bash
# On HP machine
sudo nixos-rebuild switch --flake github:drunkod/nixos-config#hp

# On laptop
sudo nixos-rebuild switch --flake github:drunkod/nixos-config#laptop

# On server
sudo nixos-rebuild switch --flake github:drunkod/nixos-config#server
```

### Advantages of Remote Rebuilds

✅ **No local clone needed** - Quick deployments  
✅ **Always up-to-date** - Pull latest changes automatically  
✅ **Consistent across machines** - Single source of truth  
✅ **Easy rollback** - Use specific commits or tags  
✅ **CI/CD friendly** - Automate deployments  

### Considerations

⚠️ **Network required** - Need internet to fetch from GitHub  
⚠️ **GitHub downtime** - Keep local clone as backup  
⚠️ **Authentication** - Configure SSH/tokens for private repos  
⚠️ **Rate limits** - GitHub API has rate limits for public repos  

### Creating a Deployment Script

Create `deploy.sh` in your repository:

```bash
#!/usr/bin/env bash
set -e

REPO="github:drunkod/nixos-config"
HOST="${1:-hp}"
ACTION="${2:-switch}"

echo "🚀 Deploying $HOST configuration from GitHub..."
echo "📦 Repository: $REPO"
echo "🎯 Action: $ACTION"
echo ""

sudo nixos-rebuild "$ACTION" --flake "$REPO#$HOST" --refresh

echo ""
echo "✅ Deployment complete!"
```

Make it executable and use:

```bash
chmod +x deploy.sh

# Deploy from GitHub
curl -fsSL https://raw.githubusercontent.com/drunkod/nixos-config/main/deploy.sh | bash -s hp switch
```

### Setting a Default Remote

You can set a system-wide configuration to always use GitHub:

Add to `nixos/configuration.nix`:

```nix
system.configurationRevision = 
  if (self ? rev) 
  then self.rev 
  else throw "Refusing to build from dirty Git tree!";

# Set NIX_PATH to point to GitHub
nix.nixPath = [
  "nixos-config=flake:github:drunkod/nixos-config"
];
```

Then you can simply run:

```bash
sudo nixos-rebuild switch
```

## 🔄 Updating

### Update All Inputs

```bash
cd ~/nixos-config

# Update all flake inputs
nix flake update

# Update specific input
nix flake lock --update-input nixpkgs

# Rebuild with updates
sudo nixos-rebuild switch --flake .#hp
```

### Update from GitHub

```bash
# Pull latest changes
cd ~/nixos-config
git pull origin main

# Update flake inputs
nix flake update

# Apply changes
sudo nixos-rebuild switch --flake .#hp
```

### Update VS Code (Flake + Home Manager/NixOS)

If `code --version` stays old after `nix flake update`, you probably have an old
imperative profile package shadowing the declarative one.

```bash
cd ~/nixos-config

# Recommended modern syntax (equivalent to lock --update-input)
nix flake update nixpkgs home-manager

# Apply flake changes
sudo nixos-rebuild switch --flake .#hp

# If VS Code is still old, remove imperative profile package
nix profile remove vscode
exec bash -l

# Verify active binary/version
which code
readlink -f "$(which code)"
code --version
```

### Automatic Updates (Optional)

Add to `nixos/configuration.nix`:

```nix
system.autoUpgrade = {
  enable = true;
  flake = "github:drunkod/nixos-config#hp";
  flags = [
    "--refresh"
  ];
  dates = "weekly";
  allowReboot = false;
};
```

## ✨ Best Practices

### 1. **Version Control Everything**

```bash
# After making changes
git add .
git commit -m "Add: description of changes"
git push origin main
```

### 2. **Use Branches for Experiments**

```bash
git checkout -b experiment-feature
# Make changes
sudo nixos-rebuild test --flake .#hp
# If successful
git checkout main
git merge experiment-feature
```

### 3. **Modular Configuration**

Split large configurations into modules:

```
nixos/
├── configuration.nix
├── hardware-configuration.nix
└── modules/
    ├── networking.nix
    ├── desktop.nix
    └── services.nix
```

Import in `configuration.nix`:
```nix
imports = [
  ./hardware-configuration.nix
  ./modules/networking.nix
  ./modules/desktop.nix
];
```

### 4. **Pin Important Inputs**

In `flake.nix`, you can pin specific versions:

```nix
inputs = {
  nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  # Or pin to specific commit
  # nixpkgs.url = "github:nixos/nixpkgs/a1b2c3d4...";
};
```

### 5. **Test Before Committing**

```bash
# Always test first
sudo nixos-rebuild test --flake .#hp

# Then switch if successful
sudo nixos-rebuild switch --flake .#hp

# Commit only if everything works
git add .
git commit -m "Update: description"
```

### 6. **Keep Hardware Config Separate**

Never commit `hardware-configuration.nix` if using multiple machines. Use `.gitignore`:

```gitignore
# .gitignore
nixos/hardware-configuration.nix
result
```

For multiple machines, organize like this:

```
nixos/
├── common.nix
└── hosts/
    ├── hp/
    │   ├── configuration.nix
    │   └── hardware-configuration.nix
    └── laptop/
        ├── configuration.nix
        └── hardware-configuration.nix
```

### 7. **Document Your Changes**

Add comments to your configuration:

```nix
# Enable Docker for development work
virtualisation.docker.enable = true;

# Custom kernel parameters for battery life
boot.kernelParams = [ "pcie_aspm=force" ];
```

### 8. **Regular Maintenance**

```bash
# Weekly: Update flakes
nix flake update

# Monthly: Clean old generations
sudo nix-collect-garbage --delete-older-than 30d

# After major changes: Optimize store
nix-store --optimize
```

### 9. **Use Overlays for Custom Packages**

Create `overlays/default.nix`:

```nix
final: prev: {
  myCustomPackage = prev.callPackage ./my-package.nix { };
}
```

### 10. **Backup Critical Data**

```bash
# Backup your configuration regularly
rsync -av ~/nixos-config /path/to/backup/

# Or use git remotes
git remote add backup git@backup-server:nixos-config.git
git push backup main
```

### 11. **Use Semantic Commit Messages**

```bash
git commit -m "feat: add hyprland window manager"
git commit -m "fix: correct espanso clipboard backend"
git commit -m "docs: update README with deployment instructions"
git commit -m "refactor: split configuration into modules"
```

### 12. **Tag Stable Releases**

```bash
# Tag a working configuration
git tag -a v1.0.0 -m "Stable configuration - January 2024"
git push origin v1.0.0

# Rebuild from stable tag
sudo nixos-rebuild switch --flake github:drunkod/nixos-config/v1.0.0#hp
```

## 🐛 Troubleshooting

### Rebuild Fails

```bash
# Check for syntax errors
nix flake check

# Build with verbose output
sudo nixos-rebuild switch --flake .#hp --show-trace
```

### Flake Lock Issues

```bash
# Refresh flake lock
rm flake.lock
nix flake update
```

### Home Manager Issues

```bash
# Rebuild only Home Manager
home-manager switch --flake .#alex -b backup

# Check Home Manager status
systemctl --user status home-manager-alex.service
```

### Out of Disk Space

```bash
# Check free space
df -h /
du -sh /nix/store

# Run Nix garbage collection to remove unreferenced store paths
nix-collect-garbage -d
nix store gc

# System-wide cleanup (recommended on NixOS)
sudo nix-collect-garbage -d

# Remove old boot entries
sudo /run/current-system/bin/switch-to-configuration boot

# Check free space again
df -h /
```

### Rollback System

```bash
# List generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Boot into previous generation
sudo nixos-rebuild switch --rollback

# Or select specific generation
sudo nixos-rebuild switch --switch-generation 123
```

### GitHub Authentication Issues

```bash
# Test SSH access
sudo ssh -T git@github.com

# Check if SSH key is loaded
sudo ssh-add -l

# Re-add SSH key
sudo ssh-add /root/.ssh/id_ed25519
```

### Flake Not Updating from GitHub

```bash
# Clear nix flake cache
sudo rm -rf ~/.cache/nix

# Force refresh
sudo nixos-rebuild switch --flake github:drunkod/nixos-config#hp --refresh --recreate-lock-file
```

## 📚 Useful Resources

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Nix Flakes Guide](https://nixos.wiki/wiki/Flakes)
- [Nix Pills](https://nixos.org/guides/nix-pills/)
- [NixOS Wiki](https://nixos.wiki/)
- [NixOS Discourse](https://discourse.nixos.org/)
- [Flake URL Specification](https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-flake.html#flake-references)

## 📝 License

This configuration is available for personal use and modification.

---

**Note**: Replace `drunkod` with your actual GitHub username and customize the configuration to match your needs.
