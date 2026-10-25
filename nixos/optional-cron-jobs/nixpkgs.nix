{ pkgs, ... }:
{
  systemd.services.nixpkgs = {
    path = with pkgs; [ gitMinimal ];

    script = ''
      if [ -e .git ]; then
        git fetch
      else
        git clone https://github.com/NixOS/nixpkgs.git .
      fi
    '';

    serviceConfig = {
      Type = "oneshot";
      CacheDirectory = "nixpkgs";
      CacheDirectoryMode = "0755";
      UMask = "0002";
      WorkingDirectory = "/var/cache/nixpkgs";
    };
  };

  lantian.harden.nixpkgs = {
    enable = true;
    enableConfinement = false;
  };

  systemd.timers.nixpkgs = {
    wantedBy = [ "timers.target" ];
    partOf = [ "nixpkgs.service" ];
    timerConfig = {
      OnCalendar = "hourly";
      Persistent = true;
      Unit = "nixpkgs.service";
      RandomizedDelaySec = "300";
    };
  };
}
