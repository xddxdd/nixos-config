{
  pkgs,
  LT,
  config,
  inputs,
  ...
}:
let
  labRoot = "/var/www/lab.lantian.pub";
in
{
  age.secrets.nginx-cgi-ssh-key = {
    file = inputs.secrets + "/drone/ssh-id-ed25519.age";
    owner = "nginx";
    group = "nginx";
  };

  lantian.nginxVhosts."lab.lantian.pub" = {
    listenHTTP.enable = true;
    root = labRoot;
    locations = {
      "/" = {
        index = "index.php index.html index.htm";
        tryFiles = "$uri $uri/ =404";
      };
      "= /".enableAutoIndex = true;
      "/cgi-bin/" = {
        index = "index.sh";
        enableFcgiwrap = true;
        disableLiveCompression = true;
      };
      "/hobby-net".enableAutoIndex = true;
      "/zjui-ece385-scoreboard".disableLiveCompression = true;

      # 307 to tools.lantian.pub
      "/dngzwxdq".return = "307 https://tools.lantian.pub$request_uri";
      "/dnyjzsxj".return = "307 https://tools.lantian.pub$request_uri";
      "/glibc-for-debian-10-on-openvz".return = "307 https://tools.lantian.pub$request_uri";
      "/mota-24".return = "307 https://tools.lantian.pub$request_uri";
      "/mota-51".return = "307 https://tools.lantian.pub$request_uri";
      "/mota-xinxin".return = "307 https://tools.lantian.pub$request_uri";
    };

    phpfpmSocket = config.services.phpfpm.pools.lab.socket;
    sslCertificate = "lantian.pub_ecc";
    noIndex.enable = true;
  };

  services.phpfpm.pools.lab = {
    phpPackage = pkgs.phpWithExtensions;
    inherit (config.services.nginx) user;
    settings = {
      "listen.owner" = config.services.nginx.user;
      "pm" = "ondemand";
      "pm.max_children" = "8";
      "pm.process_idle_timeout" = "10s";
      "pm.max_requests" = "1000";
      "pm.status_path" = "/php-fpm-status.php";
      "ping.path" = "/ping.php";
      "ping.response" = "pong";
      "request_terminate_timeout" = "300";
    };
  };

  services.fcgiwrap.instances.nginx = {
    socket = {
      inherit (config.services.nginx) user group;
      mode = "0660";
    };
    process = {
      inherit (config.services.nginx) user group;
    };
  };

  systemd.services.fcgiwrap-nginx = {
    path = with pkgs; [
      bash
      config.programs.ssh.package
      curl
      gitMinimal
      jq
    ];

    serviceConfig = LT.serviceHarden // {
      ReadWritePaths = [ "/var/www/lab.lantian.pub" ];
    };
  };

  systemd.tmpfiles.rules = [
    "L+ ${labRoot}/hobby-net - - - - /nix/persistent/sync-servers/ltnet-scripts"
    "L+ ${labRoot}/testssl.html - - - - /nix/persistent/sync-servers/www/lab.lantian.pub/testssl.htm"
  ];
}
