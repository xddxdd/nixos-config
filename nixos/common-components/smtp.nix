{ pkgs, lib, LT, config, utils, inputs, ... }@args:

let
  glauthUsers = import (inputs.secrets + "/glauth-users.nix");

  notifyScript = pkgs.writeShellScript "notify-email" ''
    MAILTO="${glauthUsers.lantian.mail}"
    HOSTNAME=$2
    UNIT=$1
    STATE=$3

    [ "$STATE" = "success" ] && FLAG="✅" || FLAG="❎"

    exec sendmail -t <<EOF
    To: $MAILTO
    Subject: $FLAG Status report for $UNIT on $HOSTNAME

    Status report for $UNIT on $HOSTNAME:

    $(systemctl status --lines=0 "$UNIT")

    $(journalctl -n 1000 _SYSTEMD_INVOCATION_ID=$(systemctl show -p InvocationID --value "$UNIT"))
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
      host = "smtp.sendgrid.net";
      port = 465;
      from = "postmaster@lantian.pub";
      user = "apikey";
      # A copy of password is in vaultwarden-env.age
      passwordeval = "cat ${config.age.secrets.smtp-pass.path}";
      tls = true;
      tls_starttls = false;
      tls_trust_file = "/etc/ssl/certs/ca-certificates.crt";
    };
  };

  systemd.services."notify-email-success@" = {
    serviceConfig = LT.serviceHarden // {
      Type = "oneshot";
      ExecStart = ''${notifyScript} "%I" "%H" "success"'';
    };
    path = with pkgs; [ inetutils msmtp ];
  };

  systemd.services."notify-email-fail@" = {
    serviceConfig = LT.serviceHarden // {
      Type = "oneshot";
      ExecStart = ''${notifyScript} "%I" "%H" "fail"'';
    };
    path = with pkgs; [ inetutils msmtp ];
  };
}
