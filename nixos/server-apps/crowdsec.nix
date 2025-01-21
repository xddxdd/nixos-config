{
  config,
  LT,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  simulation_path = "/var/lib/crowdsec/config/simulation.yaml";

  mkAcquisition = unit: {
    source = "journalctl";
    journalctl_filter = [ "_SYSTEMD_UNIT=${unit}" ];
    labels.type = "syslog";
  };
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
    acquisitions = builtins.map mkAcquisition [
      "asterisk.service"
      "endlessh.service"
      "nginx.service"
      "sshd.service"
    ];
    settings = {
      config_paths = {
        inherit simulation_path;
      };
      api.server = {
        listen_uri = "127.0.0.1:${LT.portStr.CrowdSec}";
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
      while ! cscli lapi status; do
        echo "Waiting for CrowdSec daemon to be ready"
        sleep 5
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
          echo "simulation: false" > ${simulation_path}
          cscli simulation enable crowdsecurity/http-crawl-non_statics
          cscli simulation enable crowdsecurity/http-bad-user-agent
        '')
      ];

      StateDirectory = "crowdsec";
      Restart = lib.mkForce "always";
      RestartSec = lib.mkForce "5";
    };
  };

  systemd.services.crowdsec-firewall-bouncer = {
    after = [ "crowdsec.service" ];
    requires = [ "crowdsec.service" ];
    serviceConfig = {
      Restart = lib.mkForce "always";
      RestartSec = lib.mkForce "5";
    };
  };
}
