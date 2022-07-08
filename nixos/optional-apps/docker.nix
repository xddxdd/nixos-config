{ config, pkgs, lib, ... }:

let
  LT = import ../../helpers { inherit config pkgs lib; };

  sharedPaths = [
    { name = "cache"; host = "/var/cache/ci"; vm = "/cache"; }
    { name = "sync"; host = "/nix/persistent/sync-servers"; vm = "/sync"; }
  ];

  vmPackage = (import "${pkgs.flake.nixpkgs}/nixos/default.nix" {
    configuration = {
      imports = [
        ../common-components/qemu-user-static.nix
        ../common-components/ssh-harden.nix
        ../common-components/users.nix
        ../hardware/qemu.nix
      ];

      boot.initrd.availableKernelModules = [ "9p" "9pnet_virtio" ];
      boot.loader.grub.device = "nodev";
      boot.kernelPackages = pkgs.linuxPackages_latest;

      networking = {
        hostName = "docker";
        firewall.enable = false;
        firewall.checkReversePath = false;
        nat.enable = false;
        useDHCP = false;

        interfaces.eth0.ipv4.addresses = [{ address = "10.0.2.15"; prefixLength = 24; }];
        defaultGateway = "10.0.2.2";
        nameservers = [ "8.8.8.8" "8.8.4.4" ];
      };

      nix.enable = false;
      nixpkgs.overlays = config.nixpkgs.overlays;

      fileSystems = {
        "/" = {
          device = "tmpfs";
          fsType = "tmpfs";
          options = [ "relatime" "mode=755" "size=100%" ];
        };
        "/nix/store" = {
          device = "nix-store";
          fsType = "9p";
          options = [ "ro" "trans=virtio" "version=9p2000.L" "cache=loose" ];
        };
        "/var/lib/docker" = {
          device = "/dev/vda";
          fsType = "btrfs";
          options = [ "compress-force=zstd" ];
        };
      } // (builtins.listToAttrs (builtins.map
        ({ name, host, vm }: {
          name = vm;
          value = {
            device = name;
            fsType = "9p";
            options = [ "trans=virtio" "version=9p2000.L" ];
          };
        })
        sharedPaths));

      services.journald.extraConfig = ''
        Storage=volatile
        ForwardToWall=no
      '';
      services.timesyncd.enable = false;

      virtualisation.docker = {
        enable = true;
        enableOnBoot = true;
        autoPrune = {
          enable = true;
          flags = [ "-a" ];
        };
        listenOptions = [
          "0.0.0.0:${LT.portStr.Docker}"
          "/run/docker.sock"
        ];

        daemon.settings = {
          default-runtime = "crun";
          experimental = true;
          runtimes.crun.path = "${pkgs.crun}/bin/crun";
          storage-driver = "btrfs";
          userland-proxy = false;
        };
      };

      zramSwap = {
        enable = true;
        memoryPercent = 100;
      };
    };
  }).system;

  vmStartScript = pkgs.writeShellScript "vm-start" ''
    if [ ! -f /var/lib/vm/docker.img ]; then
      echo "Please create /var/lib/vm/docker.img and format to ext4 manually"
      exit 1
    fi

    exec ${pkgs.qemu_kvm}/bin/qemu-kvm \
      -cpu host \
      -m 16384 \
      -smp 8 \
      -device virtio-rng-pci \
      -drive file=/var/lib/vm/docker.img,if=virtio,format=raw \
      -net nic,netdev=user.0,model=virtio \
      -netdev "user,id=user.0,hostfwd=tcp:127.0.0.1:${LT.portStr.Docker}-:${LT.portStr.Docker},hostfwd=tcp:127.0.0.1:2223-:2222" \
      -virtfs local,path=/nix/store,security_model=none,readonly=on,mount_tag=nix-store \
      ${builtins.concatStringsSep "\n" (builtins.map
        ({name, host, vm}: "-virtfs local,path=${host},security_model=none,mount_tag=${name} \\")
        sharedPaths)}
      -device virtio-keyboard \
      -kernel ${vmPackage}/kernel \
      -initrd ${vmPackage}/initrd \
      -append "$(cat ${vmPackage}/kernel-params) init=${vmPackage}/init console=ttyS0,115200n8" \
      -nographic
  '';
in
{
  systemd.services.docker-vm = {
    description = "Docker VM";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = "3";
      ExecStart = "${vmStartScript}";
    };
  };

  systemd.tmpfiles.rules = builtins.map
    ({ name, host, vm }: "d ${host} 755 root root")
    sharedPaths;

  environment.systemPackages = [
    (pkgs.stdenv.mkDerivation {
      name = "docker-vm";
      version = "0.0.1";

      phases = [ "installPhase" ];
      buildInputs = [ pkgs.makeWrapper ];
      installPhase = ''
        makeWrapper "${pkgs.docker}/bin/docker" "$out/bin/docker-vm" --set DOCKER_HOST "tcp://127.0.0.1:${LT.portStr.Docker}"
      '';
    })
  ];
}
