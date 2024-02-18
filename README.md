# Lan Tian's NixOS Configuration

This repository holds the configuration files for all my NixOS systems.

## Features

- [Full system root-on-tmpfs](nixos/minimal-components/impermanence.nix), using [impermanence](https://github.com/nix-community/impermanence)
- [Nftables instead of iptables](nixos/server-components/nftables.nix)
- Secret management with [agenix](https://github.com/ryantm/agenix)
- [QEMU user mode emulation for most architectures](https://github.com/xddxdd/nur-packages/blob/master/modules/qemu-user-static-binfmt.nix)
- [Nix Flakes with Nixpkgs patching](flake.nix)
- [Additional kernel modules](nixos/minimal-components/kernel/default.nix):
  - [Nftables Fullcone NAT](nixos/minimal-components/kernel/nft-fullcone.nix) sourced from [here](https://github.com/fullcone-nat-nftables/nft-fullcone)
  - [NVIDIA driver patching](nixos/minimal-components/kernel/nvlax/default.nix) based on [Nvlax](https://github.com/illnyang/nvlax)
  - [OpenVPN DCO](nixos/minimal-components/kernel/ovpn-dco.nix) sourced from [here](https://github.com/OpenVPN/ovpn-dco)
- [Post-Quantum Cryptography support for OpenSSL](nixos/minimal-components/environment.nix) based on [Open Quantum Safe](https://github.com/open-quantum-safe/oqs-provider)

## Host Types

My hosts are categorized into three types:

- `client`: A host running NixOS. Usually a desktop/laptop running a desktop environment.
- `server`: A host running NixOS without GUI. Usually a VM running on a cloud provider.

## Folder Structure

- `dns`: My custom Nix-to-DNSControl code that generates a DNSControl `config.js` file, controlling DNS records for my domains.

  - Subdirectories

    - `common`: Common records shared across domains.
    - `core`: Core component that converts a Nix attribute set into DNSControl `config.js` format.
    - `domains`: Nix definitions controlling individual (groups of) zones.

  - Files
    - `toplevel.nix`: Entrypoint called in `flake.nix`.

- `helpers`: Definitions for short cuts used by code in this repo.

- `home`: My Home Manager configurations.

  - Subdirectories

    - `common-apps`: Apps used by all nodes.
    - `client-apps`: Apps used by `client` nodes.

  - Files
    - `client.nix`: Config applied on `client` nodes.
    - `server.nix`: Config applied on `server` nodes.

- `hosts`: Host-specific NixOS system definitions. Each subdirectory refers to a host. The list of hosts is automatically obtained in `flake.nix`. Configs here usually control networking parameters, and host-specific tunings.

- `nixos`: Common NixOS system definitions.

  - Used by all nodes (auto import in `client.nix`, `minimal.nix`, `server.nix`)

    - `common-apps`: Apps used by all nodes.
    - `minimal-components`: System options used by all nodes.
      - Components differ from "Apps" that, a component is a fundamental part in the system (often by tuning kernel core parameters), while an app provides service on the userspace level.

  - Used by client nodes (auto import in `client.nix`)

    - `client-apps`
    - `client-components`

  - Used by server nodes (auto import in `server.nix`)

    - `server-apps`
    - `server-components`

  - Supplemental files
    - `hardware`: Common hardware configuration snippets, including LVM and QEMU VMs.
    - `optional-apps`: Apps that are used by some nodes. Manual imports required in host-specific definitions.
    - `optional-cron-jobs`: Cron jobs that are used by some nodes. Manual imports required in host-specific definitions.
