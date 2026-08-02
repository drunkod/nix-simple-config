# NixOS Config (Simple Guide)

This repository is a flake-based NixOS setup with Home Manager integrated.

It defines two independent machine profiles:

| Flake host | Hostname | User | System module | Home Manager profile |
| --- | --- | --- | --- | --- |
| `hp` | `HP` | `alex` | `nixos/configuration.nix` | `home-manager/home.nix` |
| `Acer` | `Acer` | `VC` | `nixos/hosts/Acer/configuration.nix` | `home-manager/users/VC.nix` |

Shared NixOS settings live in `nixos/common-configuration.nix`. Shared user packages and proxy tools live in `home-manager/common.nix`.

Alex keeps the existing Espanso profile because `home-manager/modules/espanso.nix` contains Alex-specific names and signatures. VC receives the common packages and proxy module without inheriting those personal snippets.

## Important Acer hardware step

The repository cannot safely infer Acer disk UUIDs, boot devices, CPU modules, or swap configuration from the existing HP profile. Therefore `nixos/hosts/Acer/hardware-configuration.nix` is deliberately only a safe template.

On the Acer machine, generate and copy its real hardware configuration before switching:

```bash
sudo nixos-generate-config
cp /etc/nixos/hardware-configuration.nix ./nixos/hosts/Acer/hardware-configuration.nix
```

Review the generated file and commit it to the Acer branch. Do not copy the HP hardware file: it contains HP-specific disk and CPU settings.

## Build and test

Test the existing HP configuration:

```bash
sudo nixos-rebuild test --flake .#hp
```

Test the Acer configuration after replacing its hardware template:

```bash
sudo nixos-rebuild test --flake .#Acer
```

Apply after the test succeeds:

```bash
sudo nixos-rebuild switch --flake .#Acer
```

## Main files

- `flake.nix`: defines both NixOS configurations and connects each user profile.
- `nixos/common-configuration.nix`: desktop, localization, services, packages, audio, printing, and networking shared by both hosts.
- `nixos/configuration.nix`: HP-only hostname, user, boot configuration, and disk mount.
- `nixos/hardware-configuration.nix`: generated HP hardware settings.
- `nixos/hosts/Acer/configuration.nix`: Acer hostname and VC system user.
- `nixos/hosts/Acer/hardware-configuration.nix`: replaceable Acer hardware template.
- `home-manager/common.nix`: packages and proxy module shared by Alex and VC.
- `home-manager/home.nix`: Alex identity and Alex-specific Espanso import.
- `home-manager/users/VC.nix`: VC identity and home directory.

## Update dependencies

```bash
nix flake update
sudo nixos-rebuild test --flake .#Acer
```

## Rebuild directly from GitHub

After the Acer hardware file has been committed:

```bash
sudo nixos-rebuild test --flake github:drunkod/nix-simple-config/agent/add-acer-vc#Acer --refresh
```
