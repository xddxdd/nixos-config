{
  pkgs,
  LT,
  config,
  inputs,
  ...
}:
let
  glauthUsers = import (inputs.secrets + "/glauth-users.nix");
in
{
  age.secrets.smtp-pass = {
    file = inputs.secrets + "/smtp-pass.age";
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
      user = "LyRZoFKp7S";
      passwordeval = "cat ${config.age.secrets.smtp-pass.path}";
      tls = true;
      tls_starttls = true;
      tls_trust_file = "/etc/ssl/certs/ca-certificates.crt";
    };
  };

  systemd.services."notify-email@" = {
    environment = {
      HOSTNAME = config.networking.hostName;
      SYSTEMD_PAGER = "";
    };

    path = [
      pkgs.inetutils
      pkgs.msmtp
    ];

    script = ''
      MAILTO="${glauthUsers.lantian.mail}"

      [ "$MONITOR_SERVICE_RESULT" = "success" ] && FLAG="⭕️ SUCCESS:" || FLAG="❌ FAILURE:"

      cat <<EOF | cut -c 1-80 | sendmail -t
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

    serviceConfig = LT.serviceHarden // {
      Type = "oneshot";
    };
  };
}
