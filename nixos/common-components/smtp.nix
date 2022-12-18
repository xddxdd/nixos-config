{ pkgs, lib, LT, config, utils, inputs, ... }@args:

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

  systemd.services."notify-email@" = {
    serviceConfig = LT.serviceHarden // {
      Type = "oneshot";
      ExecStart =
        let
          script = pkgs.writeShellScript "notify-email" ''
            MAILTO="$(echo ${LT.constants.emailRecipientBase64} | base64 -d)"
            HOSTNAME=$2
            UNIT=$1

            exec sendmail -t <<EOF
            To: $MAILTO
            Subject: Status report for $UNIT on $HOSTNAME

            Status report for $UNIT on $HOSTNAME:

            $(systemctl status $UNIT)

            $(journalctl -u $UNIT)
            EOF
          '';
        in
        ''${script} "%I" "%H"'';
    };
    path = with pkgs; [ inetutils msmtp ];
  };
}
