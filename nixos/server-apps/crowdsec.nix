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
    acquisitions = [
      {
        source = "journalctl";
        journalctl_filter = [ "_SYSTEMD_UNIT=sshd.service" ];
        labels.type = "syslog";
      }
      {
        source = "journalctl";
        journalctl_filter = [ "_SYSTEMD_UNIT=nginx.service" ];
        labels.type = "syslog";
      }
      {
        source = "journalctl";
        journalctl_filter = [ "_SYSTEMD_UNIT=asterisk.service" ];
        labels.type = "syslog";
      }
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
            crowdsecurity/nginx \
            crowdsecurity/sshd

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
