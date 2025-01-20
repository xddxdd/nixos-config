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

  systemd.services.crowdsec = {
    preStart = ''
      cscli hub upgrade

      # Asterisk
      cscli parsers install crowdsecurity/asterisk-logs
      cscli scenarios install crowdsecurity/asterisk_bf
      cscli scenarios install crowdsecurity/asterisk_user_enum

      # Nginx
      cscli parsers install crowdsecurity/nginx-logs
      cscli scenarios install crowdsecurity/http-admin-interface-probing
      cscli scenarios install crowdsecurity/http-backdoors-attempts
      cscli scenarios install crowdsecurity/http-bf-wordpress_bf_xmlrpc
      cscli scenarios install crowdsecurity/http-cve-2021-42013
      cscli scenarios install crowdsecurity/http-cve-probing
      cscli scenarios install crowdsecurity/http-generic-bf
      cscli scenarios install crowdsecurity/http-open-proxy
      cscli scenarios install crowdsecurity/http-path-traversal-probing
      cscli scenarios install crowdsecurity/http-sensitive-files
      cscli scenarios install crowdsecurity/http-sqli-probing
      cscli scenarios install crowdsecurity/http-wordpress_user-enum
      cscli scenarios install crowdsecurity/http-wordpress_wpconfig
      cscli scenarios install crowdsecurity/http-wordpress-scan
      cscli scenarios install crowdsecurity/http-xss-probing

      # SSH
      cscli parsers install crowdsecurity/sshd-logs
      cscli parsers install crowdsecurity/sshd-success-logs
      cscli scenarios install crowdsecurity/ssh-bf
      cscli scenarios install crowdsecurity/ssh-cve-2024-6387
      cscli scenarios install crowdsecurity/ssh-slow-bf
    '';
    postStart = ''
      cscli bouncers add cs-firewall-bouncer --key cs-firewall-bouncer || true
    '';
    serviceConfig.StateDirectory = "crowdsec";
  };

  systemd.services.crowdsec-firewall-bouncer = {
    after = [ "crowdsec.service" ];
    requires = [ "crowdsec.service" ];
  };
}
