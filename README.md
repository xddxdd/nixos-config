# Lan Tian's NixOS Configuration

This repository holds the configuration files for all my VPS nodes.

## Features

- [Full system root-on-tmpfs](common/common-components/impermanence.nix), using [impermanence](https://github.com/nix-community/impermanence)
- [Nftables instead of iptables](common/common-components/nftables.nix)
- Secret management with [agenix](https://github.com/ryantm/agenix)
- [QEMU user mode emulation for most architectures](common/common-components/qemu-user-static.nix)
- [Using Nix Flakes](flake.nix)

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
    - `components`: Modules used in Home Manager configurations.
  - Files
    - `client.nix`: Config applied on nodes with GUI. Currently this means my laptop running NixOS.
    - `non-nixos.nix`: Config applied on nodes with GUI. Currently this means my laptop running Arch Linux.
    - `server.nix`: Config applied on nodes without GUI. Currently this means all my VPS nodes.
- `hosts`: Host-specific NixOS system definitions. Each subdirectory refers to a host. The list of hosts is automatically obtained in `flake.nix`. Configs here usually control networking parameters, and host-specific tunings.
- `nixos`: Common NixOS system definitions.
  - Used by all nodes (auto import in `client.nix`, `nixos-cd.nix`, `server.nix`)
    - `common-apps`: Apps used by all nodes.
    - `common-components`: System options used by all nodes.
      - Components differ from "Apps" that, a component is a fundamental part in the system (often by tuning kernel core parameters), while an app provides service on the userspace level.
  - Used by server nodes (auto import in `server.nix`)
    - `server-apps`: Apps used by all server nodes.
    - `server-components`: System options used by all server nodes.
  - Used by client nodes (auto import in `client.nix`)
    - Nothing right now.
  - Supplemental files
    - `files`: Custom files to be imported by Nix scripts.
    - `hardware`: Common hardware configuration, including general x86_64 and QEMU VMs.
    - `optional-apps`: Apps that are used by some nodes. Manual imports required in host-specific definitions.
  - Files
    - `client.nix`: Common configuration applied to client nodes.
    - `nixos-cd.nix`: Used to create my customized NixOS installation CD.
    - `server.nix`: Common configuration applied to server nodes.
- `secrets`: Keys encrypted using [agenix](https://github.com/ryantm/agenix), with the nodes' SSH keys.
