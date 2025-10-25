{
  pkgs,
  lib,
  LT,
  ...
}:
let
  targets = [
    "lab.lantian.pub"

    "google-ssl.lantian.pub"
    "google-test-ssl.lantian.pub"
    "letsencrypt-ssl.lantian.pub"
    "letsencrypt-test-ssl.lantian.pub"
    "zerossl.lantian.pub"
  ];
in
{
  systemd.services = builtins.listToAttrs (
    builtins.map (
      k:
      lib.nameValuePair "testssl-${k}" {
        serviceConfig = LT.serviceHarden // {
          Type = "oneshot";
          ReadWritePaths = [ "/nix/persistent/sync-servers/www/${k}" ];

          # Fix ps error
          ProcSubset = "all";
        };
        unitConfig.OnFailure = "notify-email@%n.service";
        path = with pkgs; [ gawk ];
        script = ''
          ${pkgs.testssl}/bin/testssl.sh \
            -9 --wide --color 3 \
            -oH "/tmp/testssl.${k}.htm" \
            ${k} \
            > /dev/null \
            || true
          rm -f "/nix/persistent/sync-servers/www/${k}/testssl.htm"
          cat "/tmp/testssl.${k}.htm" > "/nix/persistent/sync-servers/www/${k}/testssl.htm"
        '';
      }
    ) targets
  );

  systemd.tmpfiles.settings = builtins.listToAttrs (
    builtins.map (
      k:
      lib.nameValuePair "testssl-${k}" {
        "/nix/persistent/sync-servers/www/${k}".d = {
          mode = "755";
          user = "root";
          group = "root";
        };
      }
    ) targets
  );

  systemd.timers = builtins.listToAttrs (
    builtins.map (
      k:
      lib.nameValuePair "testssl-${k}" {
        wantedBy = [ "timers.target" ];
        partOf = [ "testssl-${k}.service" ];
        timerConfig = {
          OnCalendar = "daily";
          RandomizedDelaySec = "1h";
          Unit = "testssl-${k}.service";
        };
      }
    ) targets
  );
}
