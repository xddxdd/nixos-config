{ config, pkgs, ... }:

{
  age.secrets.smtp-pass = {
    file = pkgs.secrets + "/smtp-pass.age";
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
}
