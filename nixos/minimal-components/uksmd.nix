{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ nur-xddxdd.uksmd ];
  systemd.packages = with pkgs; [ nur-xddxdd.uksmd ];
  systemd.services.uksmd = {
    enable = true;
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      CPUQuota = "10%";
    };
  };
}
