{
  pkgs,
  lib,
  LT,
  ...
}:
{

  services.suricata = {
    enable = true;

    disabledRules = [
      "re:modbus"
      "re:dnp3"
      "re:enip"
    ];

    settings = {
      host-mode = "router";

      vars.address-groups.HOME_NET = "[192.168.0.0/24]";

      af-packet = [
        {
          interface = "eth0";
          cluster-id = "1";
          cluster-type = "cluster_flow";
        }
      ];

      outputs = [
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
                };
              }
              {
                dns = {
                  requests = "yes";
                  responses = "no";
                };
              }
              {
                http = {
                  metadata = "no";
                };
              }
              { tls = { }; }
              {
                files = {
                  force-magic = "no";
                };
              }
              { stats = { }; }
            ];
          };
        }
      ];
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
