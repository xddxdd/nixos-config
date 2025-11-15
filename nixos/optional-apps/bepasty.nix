{
  pkgs,
  lib,
  LT,
  config,
  inputs,
  ...
}:
let
  host = "pb.ltn.pw";
in
{
  age.secrets.bepasty = {
    file = inputs.secrets + "/bepasty.age";
    owner = "bepasty";
    group = "bepasty";
  };
  age.secrets.bepasty-extra-config = {
    file = inputs.secrets + "/bepasty-extra-config.age";
    owner = "bepasty";
    group = "bepasty";
  };

  services.bepasty = {
    enable = true;
    servers."${host}" = {
      dataDir = "/var/lib/bepasty/data";
      workDir = "/var/lib/bepasty";
      secretKeyFile = config.age.secrets.bepasty.path;
      extraConfig = ''
        PERMANENT_SESSION=True
      '';
      extraConfigFile = config.age.secrets.bepasty-extra-config.path;
    };
  };

  lantian.nginxVhosts."${host}" = {
    locations = {
      "/" = {
        proxyPass = "http://unix:/run/bepasty/bepasty.sock";
        blockBadUserAgents = true;
      };
    };

    sslCertificate = "zerossl-ltn.pw";
    noIndex.enable = true;
  };

  systemd.services."bepasty-server-pb.ltn.pw-gunicorn".serviceConfig = LT.networkToolHarden // {
    Group = "bepasty";
    StateDirectory = "bepasty";
    User = "bepasty";

    ExecStart = lib.mkForce (
      pkgs.writeShellScript "bepasty-start" ''
        ${pkgs.python3Packages.gunicorn}/bin/gunicorn \
          bepasty.wsgi \
          --name "pb.ltn.pw" \
          --workers 3 \
          --log-level=info \
          --bind=unix:/run/bepasty/bepasty.sock \
          -k gevent
      ''
    );
    RuntimeDirectory = "bepasty";

    Restart = "always";
    RestartSec = 5;
  };

  users.groups.bepasty.members = [ "nginx" ];
}
