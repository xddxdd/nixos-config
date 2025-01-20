{
  config,
  LT,
  inputs,
  ...
}:
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
        labels.type = "journald";
      }
      {
        source = "journalctl";
        journalctl_filter = [ "_SYSTEMD_UNIT=nginx.service" ];
        labels.type = "journald";
      }
      {
        source = "journalctl";
        journalctl_filter = [ "_SYSTEMD_UNIT=asterisk.service" ];
        labels.type = "journald";
      }
    ];
    settings = {
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

  systemd.services.crowdsec.postStart = ''
    cscli bouncers add cs-firewall-bouncer --key cs-firewall-bouncer || true
  '';

  systemd.services.crowdsec-firewall-bouncer = {
    after = [ "crowdsec.service" ];
    requires = [ "crowdsec.service" ];
  };
}
