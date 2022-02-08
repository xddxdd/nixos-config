# Lan Tian's NixOS Configuration

This repository holds the configuration files for all my VPS nodes.

## Features

- [Full system root-on-tmpfs](common/required-components/impermanence.nix), using [impermanence](https://github.com/nix-community/impermanence)
- [Nftables instead of iptables](common/required-components/nftables.nix)
- Secret management with [agenix](https://github.com/ryantm/agenix)
- [QEMU user mode emulation for most architectures](common/required-components/qemu-user-static.nix)
- [Using Nix Flakes](flake.nix)

## Folder Structure

- `common`: Common NixOS system definitions.
  - Subdirectories
    - `files`: Custom config files to be imported by Nix scripts.
    - `helpers`: Definitions for short cuts in `helpers.nix`.
    - `optional-apps`: Apps that aren't used by all nodes. Manual imports required in host-specific definitions.
    - `required-apps`: Apps used by all nodes, auto imported in `common.nix`.
    - `required-components`: System options used by all nodes, auto imported in `common.nix`.
      - Components differ from "Apps" that, a component is a fundamental part in the system (often by tuning kernel core parameters), while an app provides service on the userspace level.
    - `system`: Common hardware configuration, including general x86_64 and QEMU VMs.
  - Files
    - `common.nix`: Common configuration applied to every node.
    - `helpers`: Collection of short cuts. Calls definitions in `helpers` subdirectory.
    - `home-manager.nix`: Used to apply Home Manager config. It's used directly by `flake.nix` instead of being imported in `nixosConfiguration`, so it's not located in the `required-components` subdirectory.
    - `nixos-cd.nix`: Used to create my customized NixOS installation CD.
- `dns`: My custom Nix-to-DNSControl code that generates a DNSControl `config.js` file, controlling DNS records for my domains.
  - Subdirectories
    - `common`: Common records shared across domains.
    - `core`: Core component that converts a Nix attribute set into DNSControl `config.js` format.
    - `domains`: Nix definitions controlling individual (groups of) zones.
  - Files
    - `toplevel.nix`: Entrypoint called in `flake.nix`.
- `home`: My Home Manager configurations.
  - Subdirectories
    - `components`: Modules used in Home Manager configurations.
  - Files
    - `user.nix`: Config applied on nodes without GUI. Currently this means all my VPS nodes.
    - `user-gui.nix`: Config applied on nodes with GUI. Currently this means my Arch Linux desktop.
- `hosts`: Host-specific NixOS system definitions. Each subdirectory refers to a host. The list of hosts is automatically obtained in `flake.nix`. Configs here usually control networking parameters, and host-specific tunings.
- `secrets`: Keys encrypted using [agenix](https://github.com/ryantm/agenix), with the nodes' SSH keys.
