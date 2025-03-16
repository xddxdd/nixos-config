{
  LT,
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.services.zerotierone.controller;
  ztcurl = ''${pkgs.curl}/bin/curl -fsSL -H "X-ZT1-AUTH: $(cat /var/lib/zerotier-one-controller/authtoken.secret)"'';
  zturl = "http://localhost:${builtins.toString cfg.port}";

  ipAssignmentPoolOptions = _: {
    options = {
      ipRangeStart = lib.mkOption {
        type = lib.types.str;
      };
      ipRangeEnd = lib.mkOption {
        type = lib.types.str;
      };
    };
  };

  routeOptions = _: {
    options = {
      target = lib.mkOption {
        type = lib.types.str;
      };
      via = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
      };
    };
  };

  memberOptions =
    { name, ... }:
    {
      options = {
        authorized = (lib.mkEnableOption "member to access ZeroTier network") // {
          default = true;
        };
        activeBridge = lib.mkEnableOption "member to bridge to another network";
        ipAssignments = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
        };
        name = lib.mkOption {
          type = lib.types.str;
          default = name;
        };
        noAutoAssignIps = lib.mkEnableOption "skip auto assign IP for this member";
        ssoExempt = lib.mkEnableOption "skip SSO for this member";
      };
    };

  networkOptions =
    { name, config, ... }:
    let
      jsonPayload = builtins.toJSON {
        inherit (config)
          name
          enableBroadcast
          mtu
          private
          ipAssignmentPools
          v4AssignMode
          v6AssignMode
          multicastLimit
          routes
          ;
      };
      generatedSetupScript =
        ''
          ZTADDR=$(${ztcurl} "${zturl}/status" | ${pkgs.jq}/bin/jq -r ".address")
          ${ztcurl} -XPOST "${zturl}/controller/network/''${ZTADDR}${name}" -d ${lib.escapeShellArg jsonPayload}
        ''
        + (lib.concatStrings (
          lib.mapAttrsToList (n: v: ''
            ${ztcurl} -XPOST "${zturl}/controller/network/''${ZTADDR}${name}/member/${n}" -d ${lib.escapeShellArg (builtins.toJSON v)}
          '') config.members
        ));
    in
    {
      options = {
        enable = (lib.mkEnableOption "ZeroTier network") // {
          default = true;
        };
        name = lib.mkOption {
          type = lib.types.str;
          default = name;
        };
        enableBroadcast = (lib.mkEnableOption "Broadcast within network") // {
          default = true;
        };
        mtu = lib.mkOption {
          type = lib.types.int;
          default = 2800;
        };
        private = (lib.mkEnableOption "manual authorization when joining network") // {
          default = true;
        };
        ipAssignmentPools = lib.mkOption {
          type = lib.types.listOf (lib.types.submodule ipAssignmentPoolOptions);
          description = "IP pools to auto assign IPs from. If you do not use auto assignment, please use the default value, otherwise networking will not work between hosts.";
          default = [
            {
              ipRangeStart = "203.0.113.1";
              ipRangeEnd = "203.0.113.254";
            }
            {
              ipRangeStart = "fe80::1";
              ipRangeEnd = "fe80::ffff";
            }
          ];
        };
        v4AssignMode.zt = lib.mkEnableOption "auto assign IPv4 address by ZeroTier";
        v6AssignMode."6plane" =
          lib.mkEnableOption "auto assign IPv6 address with 6plane method by ZeroTier";
        v6AssignMode.rfc4193 = lib.mkEnableOption "auto assign IPv6 address with RFC4193 method by ZeroTier";
        v6AssignMode.zt = lib.mkEnableOption "auto assign IPv6 address with ZeroTier's own method";
        multicastLimit = lib.mkOption {
          type = lib.types.int;
          default = 0;
        };
        routes = lib.mkOption {
          type = lib.types.listOf (lib.types.submodule routeOptions);
          default = [ ];
        };

        members = lib.mkOption {
          type = lib.types.attrsOf (lib.types.submodule memberOptions);
          default = { };
        };

        _script = lib.mkOption {
          readOnly = true;
          default = generatedSetupScript;
        };
      };
    };
in
{
  options.services.zerotierone.controller = {
    enable = lib.mkEnableOption "ZeroTier self-hosted controller";
    port = lib.mkOption {
      description = "Port the ZeroTier controller listens on";
      type = lib.types.int;
      default = 9994;
    };
    networks = lib.mkOption {
      description = "Network ID suffixes to be added to ZeroTier controller";
      type = lib.types.attrsOf (lib.types.submodule networkOptions);
      default = { };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.zerotierone-controller = {
      description = "ZeroTier One Controller";
      wantedBy = [ "multi-user.target" ];

      serviceConfig = LT.serviceHarden // {
        ExecStart = "${pkgs.zerotierone}/bin/zerotier-one -p${builtins.toString cfg.port} -U /var/lib/zerotier-one-controller";
        StateDirectory = "zerotier-one-controller";
        WorkingDirectory = "/var/lib/zerotier-one-controller";

        User = "zerotierone-controller";
        Group = "zerotierone-controller";
      };
    };

    systemd.services.zerotierone-controller-setup = {
      description = "ZeroTier One Controller Setup";
      wantedBy = [ "multi-user.target" ];
      after = [ "zerotierone-controller.service" ];
      requires = [ "zerotierone-controller.service" ];

      script = lib.concatStrings (lib.mapAttrsToList (_n: v: v._script) cfg.networks);

      serviceConfig = LT.serviceHarden // {
        Type = "oneshot";
        StateDirectory = "zerotier-one-controller";
        WorkingDirectory = "/var/lib/zerotier-one-controller";

        User = "zerotierone-controller";
        Group = "zerotierone-controller";
        Restart = "on-failure";
        RestartSec = "5";
      };
    };

    users.users.zerotierone-controller = {
      group = "zerotierone-controller";
      isSystemUser = true;
    };
    users.groups.zerotierone-controller = { };
  };
}
