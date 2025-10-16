{ pkgs, ... }:
{
  systemd.services.smartctl-enable = {
    description = "Enable SMART for drives";
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      Restart = "on-failure";
      RestartSec = "5";
    };

    path = [ pkgs.smartmontools ];

    script = ''
      for F in /dev/sd[a-z]; do
        smartctl --smart=on "$F"
      done
    '';
  };
}
