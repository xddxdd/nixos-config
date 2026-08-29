{
  pkgs,
  lib,
  LT,
  config,
  ...
}:
let
  cfg = config.lantian.ocfs2;

  # The local node's O2CB IP — used to wait for the interconnect to be up
  # before registering, so we don't race the network at boot.
  localNode = lib.findFirst (n: n.name == LT.this.name) null cfg.nodes;
  localIp = localNode.ip;

  # jconfig (the cluster.conf parser) only treats a line as an attribute if it
  # starts with whitespace; stanza headers must sit at column 0. So attribute
  # lines are indented two spaces and `cluster:`/`node:`/`heartbeat:` are not.
  clusterConf = ''
    cluster:
      node_count = ${toString (builtins.length cfg.nodes)}
      name = ${cfg.clusterName}
      heartbeat_mode = ${cfg.heartbeatMode}

  ''
  + lib.concatMapStrings (n: ''
    node:
      ip_port = ${toString cfg.clusterPort}
      ip_address = ${n.ip}
      number = ${toString n.number}
      name = ${n.name}
      cluster = ${cfg.clusterName}

  '') cfg.nodes
  + lib.concatMapStrings (r: ''
    heartbeat:
      cluster = ${cfg.clusterName}
      region = ${r}

  '') cfg.heartbeatRegions;
in
{
  options.lantian.ocfs2 = {
    enable = lib.mkEnableOption "OCFS2 O2CB cluster stack, generating /etc/ocfs2/cluster.conf and the o2cb service";

    clusterName = lib.mkOption {
      type = lib.types.str;
      default = LT.this.interconnect.name or "ocfs2";
      description = "OCFS2 cluster name (must match across all nodes). Defaults to the interconnect fabric name.";
    };

    clusterPort = lib.mkOption {
      type = lib.types.port;
      default = LT.port.OCFS2;
      description = "O2CB inter-node communication port.";
    };

    heartbeatMode = lib.mkOption {
      type = lib.types.enum [
        "local"
        "global"
      ];
      default = "global";
      description = ''
        OCFS2 heartbeat mode written into cluster.conf.
        `global` requires `heartbeatRegions` listing the OCFS2 device UUID(s)
        and is the recommended mode (matches `mkfs.ocfs2 --global-heartbeat`).
        `local` heartbeats via the mounted journal and needs no regions.
      '';
    };

    heartbeatRegions = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = ''
        Heartbeat region UUIDs (the OCFS2 filesystem UUID of each shared
        device), used only when `heartbeatMode = "global"`. Obtain via
        `tunefs.ocfs2 -Q "%U\n" <device>`. Must be identical on every node.
      '';
    };

    nodes = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            name = lib.mkOption {
              type = lib.types.str;
              description = "Node name (must match the host's short hostname).";
            };
            ip = lib.mkOption {
              type = lib.types.str;
              description = "O2CB inter-node IP address of this node.";
            };
            number = lib.mkOption {
              type = lib.types.int;
              description = "Unique OCFS2 node number (slot). Must be unique across the cluster.";
            };
          };
        }
      );
      default = [ ];
      description = "Cluster members. Must be identical on every node. Only include hosts that share the block device.";
    };

    mounts = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            mountPoint = lib.mkOption {
              type = lib.types.str;
              description = "Mount point for the OCFS2 filesystem.";
            };
            device = lib.mkOption {
              type = lib.types.str;
              description = "Block device path (shared LUN) to mount.";
            };
            options = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ "noatime" ];
              description = "Additional mount options.";
            };
          };
        }
      );
      default = [ ];
      description = "OCFS2 filesystems to mount. Wired to require the o2cb service.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.nur-xddxdd.ocfs2-tools ];

    # Load the OCFS2/O2CB stack modules at boot so the service only has to
    # mount the pseudo-filesystems and register the cluster.
    boot.kernelModules = [
      "configfs"
      "ocfs2_stackglue"
      "ocfs2_stack_o2cb"
      "ocfs2_dlmfs"
      "ocfs2"
    ];

    environment.etc."ocfs2/cluster.conf".text = clusterConf;

    assertions = [
      {
        assertion = builtins.length cfg.nodes > 0;
        message = "lantian.ocfs2 is enabled but no cluster members were provided (set `nodes`).";
      }
      {
        assertion = localNode != null;
        message = "lantian.ocfs2: current host `${LT.this.name}` is not listed in `nodes`; every cluster member must include itself.";
      }
      {
        assertion = cfg.heartbeatMode == "local" || builtins.length cfg.heartbeatRegions > 0;
        message = ''lantian.ocfs2: heartbeatMode="global" requires at least one `heartbeatRegions` UUID (run `tunefs.ocfs2 -Q "%U\n" <device>` and add it).'';
      }
    ];

    systemd.services.o2cb = {
      description = "OCFS2 O2CB cluster stack";
      after = [
        "systemd-modules-load.service"
        "network-online.target"
      ];
      wants = [
        "systemd-modules-load.service"
        "network-online.target"
      ];
      wantedBy = [ "multi-user.target" ];

      path = [
        pkgs.nur-xddxdd.ocfs2-tools
        pkgs.kmod
        pkgs.util-linux
        pkgs.coreutils
        pkgs.iproute2
      ];

      preStart = ''
        mkdir -p /sys/kernel/config /dlm
        mountpoint -q /sys/kernel/config || mount -t configfs none /sys/kernel/config
        if [ -f /sys/fs/ocfs2/cluster_stack ]; then
          echo o2cb > /sys/fs/ocfs2/cluster_stack
        fi
        mountpoint -q /dlm || mount -t ocfs2_dlmfs none /dlm
      '';

      script = ''
        # Wait for this node's O2CB IP to be bound. If the interconnect tunnel
        # isn't up yet, fail so systemd restarts us after RestartSec instead of
        # declaring success and letting the .mount unit fail with
        # "Cluster name is invalid while trying to join the group".
        ip -o addr show | grep -qw ${localIp} || exit 1

        # register-cluster is idempotent (returns 0 if the cluster already
        # exists), but start-heartbeat is not. Only bring the cluster up when
        # it isn't already online, so restarting the service is safe.
        if ! o2cb cluster-status ${cfg.clusterName}; then
          o2cb register-cluster ${cfg.clusterName}
          ${lib.optionalString (cfg.heartbeatMode == "global") ''
            o2cb start-heartbeat ${cfg.clusterName}
          ''}
          o2hbmonitor
        fi

        # Only declare success once the cluster is actually online, otherwise
        # the mount races ahead and fails.
        o2cb cluster-status ${cfg.clusterName}
      '';

      postStop = ''
        if o2cb cluster-status ${cfg.clusterName}; then
          o2cb stop-heartbeat ${cfg.clusterName}
          o2cb unregister-cluster ${cfg.clusterName}
        fi
        mountpoint -q /dlm && umount /dlm
      '';

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        # Retry through the boot-time network race until the interconnect is up.
        Restart = "on-failure";
        RestartSec = 5;
      };
    };

    fileSystems = lib.listToAttrs (
      map (m: {
        name = m.mountPoint;
        value = {
          inherit (m) device;
          fsType = "ocfs2";
          # x-systemd.* are honored by systemd's fstab generator, so the
          # generated .mount unit waits for the O2CB stack before mounting.
          options = lib.unique (
            [
              "_netdev"
              "noatime"
              "x-systemd.requires=o2cb.service"
              "x-systemd.after=o2cb.service"
            ]
            ++ m.options
          );
        };
      }) cfg.mounts
    );
  };
}
