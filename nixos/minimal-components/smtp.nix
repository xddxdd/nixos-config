{
  pkgs,
  LT,
  config,
  lib,
  ...
}:
{
  sops.secrets.smtp-pass = {
    sopsFile = LT.secret "common/smtp.yaml";
    mode = "0444";
  };

  programs.msmtp = {
    enable = true;
    accounts.default = {
      auth = true;
      host =
        if
          builtins.elem LT.this.city.country [
            "US"
            "CA"
            "MX"
          ]
        then
          "send-us.ahasend.com"
        else
          "send.ahasend.com";
      port = 587;
      from = "postmaster@lantian.pub";
      user = "3BWqcaJjWk";
      passwordeval = "${pkgs.coreutils}/bin/cat ${lib.escapeShellArg config.sops.secrets.smtp-pass.path}";
      tls = true;
      tls_starttls = true;
      tls_trust_file = "/etc/ssl/certs/ca-certificates.crt";
    };
  };

  lantian.harden."notify-email@" = {
    enable = true;
    # 通知脚本需要真实 journalctl 读取失败单元的日志，因此依赖 systemd。
    enableTripwire = false;
    etc = {
      msmtprc = true;
    };
  };
  systemd.services."notify-email@" = {
    environment = {
      HOSTNAME = config.networking.hostName;
      SYSTEMD_PAGER = "";
    };

    path = [
      config.systemd.package
      pkgs.inetutils
      pkgs.msmtp
    ];

    script = ''
      MAILTO="lantian@lantian.pub"

      [ "$MONITOR_SERVICE_RESULT" = "success" ] && FLAG="⭕️ SUCCESS:" || FLAG="❌ FAILURE:"

      sendmail -t <<EOF
      To: $MAILTO
      Subject: $FLAG $MONITOR_UNIT on $HOSTNAME

      $FLAG $MONITOR_UNIT on $HOSTNAME:

      Hostname:       $HOSTNAME
      Unit:           $MONITOR_UNIT
      Service result: $MONITOR_SERVICE_RESULT
      Exit code:      $MONITOR_EXIT_CODE
      Exit status:    $MONITOR_EXIT_STATUS

      $(journalctl -n 1000 --no-pager -o short-unix --no-hostname --all _SYSTEMD_INVOCATION_ID=$MONITOR_INVOCATION_ID)
      EOF
    '';

    serviceConfig = {
      Type = "oneshot";
      BindReadOnlyPaths = [
        config.sops.secrets.smtp-pass.path
        "/var/log/journal"
      ];
    };
  };
}
