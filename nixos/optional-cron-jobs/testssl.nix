{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
}@args:
let
  targets = [
    "lab.lantian.pub"

    "buypass-ssl.lantian.pub"
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
        unitConfig.OnFailure = "notify-email-fail@%n.service";
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

  systemd.tmpfiles.rules = builtins.map (
    k: "d /nix/persistent/sync-servers/www/${k} 755 root root"
  ) targets;

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
