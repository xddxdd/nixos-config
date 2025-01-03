{ pkgs, lib, ... }:
let
  bilibili-tool-pro = pkgs.writeShellScriptBin "bilibili-tool-pro" ''
    exec ${pkgs.podman}/bin/podman run \
      --rm \
      -v '/var/lib/bilibili-tool-pro/appsettings.json:/app/appsettings.json' \
      -v '/var/lib/bilibili-tool-pro/cookies.json:/app/cookies.json' \
      --pull always \
      --entrypoint "dotnet" \
      ghcr.io/raywangqvq/bilibili_tool_pro \
      /app/Ray.BiliBiliTool.Console.dll \
      "$@"
  '';
in
{
  lantian.enablePodman = lib.mkForce true;

  environment.systemPackages = [ bilibili-tool-pro ];

  systemd.services.bilibili-tool-pro = {
    script = ''
      ${bilibili-tool-pro}/bin/bilibili-tool-pro --runTasks=Daily | tee run.log 2>&1
      grep "请检查Cookie" run.log && exit 1 || exit 0
    '';

    serviceConfig = {
      Type = "oneshot";
      TimeoutSec = 3600;
      Restart = "on-failure";
      RestartSec = "1800";
      RuntimeDirectory = "bilibili-tool-pro";
      WorkingDirectory = "/run/bilibili-tool-pro";
    };
    unitConfig = {
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
