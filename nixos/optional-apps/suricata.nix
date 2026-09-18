{
  pkgs,
  lib,
  LT,
  ...
}:
{

  services.suricata = {
    enable = true;
    reloadOnRulesetUpdate = true;

    disabledRules = [
      "re:modbus"
      "re:dnp3"
      "re:enip"

      # Suricata's own event rules (*-events.rules shipped with suricata;
      # files.rules kept as it powers filestore/fileinfo)
      "group:*-events.rules"
      "re:ZeroTier"
      "group:emerging-dyn_dns.rules"
      "re:Query for \\.[a-z]+ TLD"
      "re:Query to a .* domain - Likely Hostile"
      "re:DNS request .*extension\""
      "re:extension observed\""
      "re:Query for Suspicious"

      "re:classtype:policy-violation"
      "re:classtype:misc-activity"
      "re:classtype:misc-attack"
      "re:classtype:network-scan"
    ];

    enabledRules = [
      # TrafficID rules: alert on >X uploaded to a public IP via TLS/SSH
      # (possible data exfiltration; thresholds 10MB-10GB); disabled by
      # default in the ruleset
      "re:Possible data exfiltration"
    ];

    # Whitelist 88.99.66.151: suppress all alert rules
    # for connections to it (gen_id 0 / sig_id 0 = all rules)
    settings.threshold-file = builtins.toString (
      pkgs.writeText "suricata-threshold.config" (
        ''
          # eu.nixbuild.net
          suppress gen_id 0, sig_id 0, track by_dst, ip 88.99.66.151
          # u378583.your-storagebox.de
          suppress gen_id 0, sig_id 0, track by_dst, ip 91.98.242.217
        ''
        + lib.concatMapStrings (
          v:
          lib.concatMapStrings (ip: ''
            suppress gen_id 0, sig_id 0, track by_either, ip ${ip}
          '') v._addresses
        ) (builtins.attrValues LT.hosts)
      )
    );

    settings.outputs = [
      {
        eve-log = {
          enabled = true;
          filetype = "regular";
          filename = "eve.json";
          community-id = true;
          types = [
            {
              alert = {
                tagged-packets = "yes";
                verdict = "yes";
                metadata = {
                  app-layer = true;
                  flow = true;
                  rule = {
                    metadata = true;
                    raw = true;
                    reference = true;
                  };
                };
              };
            }
            {
              dns = {
                requests = "yes";
                responses = "yes";
              };
            }
            {
              http = {
                extended = "yes";
                dump-all-headers = "both";
              };
            }
            {
              tls = {
                extended = "yes";
                session-resumption = "yes";
              };
            }
            { files.force-magic = "yes"; }
            {
              stats = {
                totals = "yes";
                threads = "yes";
                deltas = "yes";
              };
            }
            { smtp.extended = "yes"; }
            { arp.enabled = "yes"; }
            { dhcp.extended = "yes"; }
            { dcerpc = { }; }
            { doh2 = { }; }
            { flow = { }; }
            { ftp = { }; }
            { http2 = { }; }
            { ike = { }; }
            { krb5 = { }; }
            { ldap = { }; }
            { mdns = { }; }
            { metadata = { }; }
            { mqtt = { }; }
            { nfs = { }; }
            { pop3 = { }; }
            { quic = { }; }
            { rdp = { }; }
            { rfb = { }; }
            { sip = { }; }
            { smb = { }; }
            { snmp = { }; }
            { ssh = { }; }
            { tftp = { }; }
            { websocket = { }; }
          ];
        };
      }
    ];
  };

  systemd.services.suricata.serviceConfig.TimeoutStartSec = "5min";

  services.logrotate = {
    enable = true;
    settings = {
      suricata = {
        files = "/var/log/suricata/*";
        su = "suricata suricata";
        frequency = "daily";
        rotate = 5;
        copytruncate = true;
        compress = true;
      };
    };
  };

  systemd.services.evebox = {
    description = "EveBox (Suricata event viewer)";
    wantedBy = [ "multi-user.target" ];
    after = [ "suricata.service" ];
    serviceConfig = LT.serviceHarden // {
      # FIXME: hardcoded IP
      ExecStart = ''
        ${lib.getExe pkgs.evebox} server --sqlite \
          --data-directory /var/lib/evebox \
          --input /var/log/suricata/eve.json --end \
          --host 192.168.0.1 --port 5636
      '';
      StateDirectory = "evebox";
      User = "suricata";
      Group = "suricata";
      Restart = "always";
    };
  };
}
