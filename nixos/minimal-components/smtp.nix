{
  pkgs,
  LT,
  config,
  inputs,
  ...
}:
let
  glauthUsers = import (inputs.secrets + "/glauth-users.nix");

  notifyScript = pkgs.writeShellScript "notify-email" ''
    MAILTO="${glauthUsers.lantian.mail}"
    HOSTNAME=$2
    UNIT=$1
    STATE=$3

    [ "$STATE" = "success" ] && FLAG="⭕️ SUCCESS:" || FLAG="❌ FAILURE:"

    export SYSTEMD_PAGER=""

    cat <<EOF | cut -c 1-80 | sendmail -t
    To: $MAILTO
    Subject: $FLAG $UNIT on $HOSTNAME

    $FLAG $UNIT on $HOSTNAME:

    $(systemctl status --lines=0 "$UNIT")

    $(journalctl -n 1000 --no-pager -o short-unix --no-hostname --all -u "$UNIT")
    EOF
  '';
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

  systemd.services."notify-email-success@" = {
    serviceConfig = LT.serviceHarden // {
      Type = "oneshot";
      ExecStart = ''${notifyScript} "%I" "%H" "success"'';
    };
    path = with pkgs; [
      inetutils
      msmtp
    ];
  };

  systemd.services."notify-email-fail@" = {
    serviceConfig = LT.serviceHarden // {
      Type = "oneshot";
      ExecStart = ''${notifyScript} "%I" "%H" "fail"'';
    };
    path = with pkgs; [
      inetutils
      msmtp
    ];
  };
}
