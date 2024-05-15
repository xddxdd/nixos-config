{ pkgs, lib, ... }:
{
  lantian.enablePodman = lib.mkForce true;

  systemd.services.bilibili-tool-pro = {
    path = with pkgs; [ podman ];
    script = ''
      exec podman run \
        --rm \
        -v '/var/lib/bilibili-tool-pro/appsettings.json:/app/appsettings.json' \
        -v '/var/lib/bilibili-tool-pro/cookies.json:/app/cookies.json' \
        --pull always \
        --entrypoint "/bin/bash" \
        ghcr.io/raywangqvq/bilibili_tool_pro \
        -c "cd /app && dotnet Ray.BiliBiliTool.Console.dll --runTasks=Daily"
    '';
    serviceConfig = {
      Type = "oneshot";
      TimeoutSec = 3600;
      Restart = "on-failure";
      RestartSec = "1800";
    };
    unitConfig = {
      OnSuccess = "notify-email-success@%n.service";
      OnFailure = "notify-email-fail@%n.service";
    };
    after = [ "network.target" ];
  };

  systemd.timers.bilibili-tool-pro = {
    wantedBy = [ "timers.target" ];
    partOf = [ "bilibili-tool-pro.service" ];
    timerConfig = {
      OnCalendar = [
        "*-*-* 02:30:00"
        "*-*-* 14:30:00"
      ];
      Persistent = true;
      RandomizedDelaySec = "4h";
      Unit = "bilibili-tool-pro.service";
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/bilibili-tool-pro 755 root root"
    "f /var/lib/bilibili-tool-pro/appsettings.json 755 root root - {}"
    "f /var/lib/bilibili-tool-pro/cookies.json 755 root root - {}"
  ];
}
