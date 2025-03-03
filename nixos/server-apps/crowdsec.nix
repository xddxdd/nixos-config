{
  config,
  LT,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  configPath = "/var/lib/crowdsec/config";

  mkAcquisition =
    enable: unit:
    if enable then
      {
        source = "journalctl";
        journalctl_filter = [ "_SYSTEMD_UNIT=${unit}" ];
        labels.type = "syslog";
      }
    else
      null;

  whitelistFile = pkgs.writeText "whitelist.yaml" (
    builtins.toJSON {
      name = "lantian_whitelist";
      description = "Lan Tian's Whitelist";
      whitelist = {
        reason = "Lan Tian's Whitelist";
        ip = builtins.filter (v: v != null && v != "") (
          lib.flatten (
            lib.mapAttrsToList (_n: v: [
              v.public.IPv4
              v.public.IPv6
              v.public.IPv6Alt
            ]) LT.hosts
          )
        );
        cidr =
          LT.constants.reserved.IPv4
          ++ LT.constants.reserved.IPv6
          ++ [
            "104.156.105.0/24"
          ];
      };
    }
  );
in
{
  age.secrets.crowdsec-enroll-key = {
    file = inputs.secrets + "/crowdsec-enroll-key.age";
    owner = "crowdsec";
    group = "crowdsec";
  };

  services.crowdsec = {
    enable = true;
    enrollKeyFile = config.age.secrets.crowdsec-enroll-key.path;
    allowLocalJournalAccess = true;
    acquisitions = builtins.filter (v: v != null) [
      (mkAcquisition config.services.asterisk.enable "asterisk.service")
      (mkAcquisition config.services.endlessh.enable "endlessh.service")
      (mkAcquisition config.services.nginx.enable "nginx.service")
      (mkAcquisition config.services.openssh.enable "sshd.service")
    ];
    settings = {
      config_paths = {
        simulation_path = "${configPath}/simulation.yaml";
      };
      api.server = {
        listen_uri = "127.0.0.1:${LT.portStr.CrowdSec}";
      };
      prometheus = {
        enabled = true;
        level = "full";
        listen_addr = LT.this.ltnet.IPv4;
        listen_port = LT.port.Prometheus.CrowdSec;
      };
    };
  };

  services.crowdsec-firewall-bouncer = {
    enable = true;
    settings = {
      api_url = "http://127.0.0.1:${LT.portStr.CrowdSec}";
      api_key = "cs-firewall-bouncer";
      mode = "nftables";
      nftables = {
        ipv4 = {
          enabled = true;
          set-only = false;
          table = "crowdsec";
          chain = "crowdsec-chain";
        };
        ipv6 = {
          enabled = true;
          set-only = false;
          table = "crowdsec6";
          chain = "crowdsec6-chain";
        };
      };
    };
  };

  systemd.services.crowdsec = {
    # Fix journald parsing error
    environment = {
      LANG = "C.UTF-8";
    };
    postStart = ''
      while ! nice -n19 cscli lapi status; do
        echo "Waiting for CrowdSec daemon to be ready"
        sleep 15
      done

      cscli bouncers add cs-firewall-bouncer --key cs-firewall-bouncer || true
    '';
    serviceConfig = {
      ExecStartPre = lib.mkAfter [
        (pkgs.writeShellScript "crowdsec-packages" ''
          cscli hub upgrade

          cscli collections install \
            crowdsecurity/asterisk \
            crowdsecurity/endlessh \
            crowdsecurity/linux \
            crowdsecurity/nginx \
            crowdsecurity/nginx-proxy-manager \
            crowdsecurity/sshd

          cscli postoverflows install \
            crowdsecurity/cdn-qc-whitelsit \
            crowdsecurity/cdn-whitelist \
            crowdsecurity/discord-crawler-whitelist \
            crowdsecurity/ipv6_to_range \
            crowdsecurity/rdns \
            crowdsecurity/seo-bots-whitelist

          # Disable rules I do not want
          echo "simulation: false" > ${configPath}/simulation.yaml
          cscli simulation enable crowdsecurity/http-bad-user-agent
          cscli simulation enable crowdsecurity/http-crawl-non_statics
          cscli simulation enable crowdsecurity/http-probing

          # Install whitelist
          install -Dm644 ${whitelistFile} ${configPath}/parsers/s02-enrich/lantian_whitelist.yaml
        '')
      ];

      CPUQuota = "50%";
      StateDirectory = "crowdsec";
      Restart = lib.mkForce "always";
      RestartSec = lib.mkForce "5";
      TimeoutStartSec = 3600;
    };
  };

  systemd.services.crowdsec-firewall-bouncer =
    lib.mkIf config.services.crowdsec-firewall-bouncer.enable
      {
        after = [ "crowdsec.service" ];
        requires = [ "crowdsec.service" ];
        serviceConfig = {
          Restart = lib.mkForce "always";
          RestartSec = lib.mkForce "5";
        };
      };
}
