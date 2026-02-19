# NixOS Config (Simple Guide)

This repo is a flake-based NixOS setup with Home Manager integrated.

It currently defines:
- Host: `hp`
- User: `alex`
- Main files:
  - `flake.nix`
  - `nixos/configuration.nix`
  - `home-manager/home.nix`

## What each file does

- `flake.nix`: wires everything together and defines `nixosConfigurations.hp`
- `nixos/configuration.nix`: system settings (boot, desktop, services, users)
- `nixos/hardware-configuration.nix`: hardware-specific settings for your machine
- `home-manager/home.nix`: user packages and user-level config
- `home-manager/modules/*`: extra Home Manager modules (espanso/proxy)

## Quick start (local repo)

1. Clone this repo:

```bash
git clone https://github.com/drunkod/nixos-config.git ~/nixos-config
cd ~/nixos-config
```

2. Back up your current NixOS config:

```bash
sudo cp -r /etc/nixos /etc/nixos.backup
```

3. Copy your machine hardware config into this repo:

```bash
sudo cp /etc/nixos/hardware-configuration.nix ~/nixos-config/nixos/
```

4. Build and switch:

```bash
sudo nixos-rebuild switch --flake ~/nixos-config#hp
```

## Daily use

- Test changes without switching:

```bash
sudo nixos-rebuild test --flake .#hp
```

- Apply system + Home Manager changes:

```bash
sudo nixos-rebuild switch --flake .#hp
```

- Roll back if needed:

```bash
sudo nixos-rebuild switch --rollback
```

## Where to edit

- Add system packages: `nixos/configuration.nix` in `environment.systemPackages`
- Add user packages: `home-manager/home.nix` in `home.packages`
- Change hostname/timezone/user: `nixos/configuration.nix`

After editing, run:

```bash
sudo nixos-rebuild switch --flake .#hp
```

## Update dependencies

```bash
nix flake update
sudo nixos-rebuild switch --flake .#hp
```

## Rebuild directly from GitHub (optional)

```bash
nix flake update
sudo nixos-rebuild switch --flake github:drunkod/nixos-config#hp --refresh

```

Use this when you do not want to clone locally.

## Common problems

- Error about missing hardware config:
  - Ensure `nixos/hardware-configuration.nix` exists for this machine.
- Syntax/build error:
  - Run `sudo nixos-rebuild switch --flake .#hp --show-trace`
- Home Manager service issue:
  - Rebuild with full system command above (Home Manager is integrated into NixOS module).
