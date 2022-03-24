# Lan Tian's NixOS Configuration

This repository holds the configuration files for all my VPS nodes.

## Features

- [Full system root-on-tmpfs](nixos/common-components/impermanence.nix), using [impermanence](https://github.com/nix-community/impermanence)
- [Nftables instead of iptables](nixos/server-components/nftables.nix)
- Secret management with [agenix](https://github.com/ryantm/agenix)
- [QEMU user mode emulation for most architectures](nixos/common-components/qemu-user-static.nix)
- [Using Nix Flakes](flake.nix)

## Host Types

My hosts are categorized into three types:

- `client`: A host running NixOS. Usually a desktop/laptop running a desktop environment.
- `non-nixos`: A host running another Linux distribution, with a GUI. Usually only Home-Manager settings are applied.
- `server`: A host running NixOS without GUI. Usually a VM running on a cloud provider.

In addition, there is a virtual (combined) category:

- `gui`: Includes all hosts from `client` and `non-nixos`

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
    - `gui-apps`: Apps used by `client` and `non-nixos` nodes.
    - `non-nixos-apps`: Apps used by `non-nixos` nodes.

  - Files
    - `client.nix`: Config applied on `client` nodes.
    - `non-nixos.nix`: Config applied on `non-nixos` nodes.
    - `server.nix`: Config applied on `server` nodes.

- `hosts`: Host-specific NixOS system definitions. Each subdirectory refers to a host. The list of hosts is automatically obtained in `flake.nix`. Configs here usually control networking parameters, and host-specific tunings.

- `nixos`: Common NixOS system definitions.
  - Used by all nodes (auto import in `client.nix`, `nixos-cd.nix`, `server.nix`)
    - `common-apps`: Apps used by all nodes.
    - `common-components`: System options used by all nodes.
      - Components differ from "Apps" that, a component is a fundamental part in the system (often by tuning kernel core parameters), while an app provides service on the userspace level.

  - Used by client nodes (auto import in `client.nix`)
    - `client-apps`
    - `client-components`

  - Used by server nodes (auto import in `server.nix`)
    - `server-apps`
    - `server-components`

  - Supplemental files
    - `hardware`: Common hardware configuration, including general x86_64 and QEMU VMs.
    - `nixos-cd.nix`: Used to create my customized NixOS installation CD.
    - `optional-apps`: Apps that are used by some nodes. Manual imports required in host-specific definitions.
