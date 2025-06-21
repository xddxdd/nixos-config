{
  pkgs,
  LT,
  config,
  ...
}:
let
  flapalerted = pkgs.nur-xddxdd.flapalerted.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      ../../patches/flapalerted-listen-localhost.patch
    ];
  });
in
{
  systemd.services.flapalerted = {
    description = "FlapAlerted";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    requires = [ "network.target" ];

    script = ''
      exec ${flapalerted}/bin/FlapAlerted \
        --asn 4242422547 \
        --bgpPort [${LT.this.ltnet.IPv6}]:${LT.portStr.FlapAlerted.BGP} \
        --httpApiPort ${LT.portStr.FlapAlerted.WebUI} \
        --limitedHttpApi \
        --minimumAge 60
    '';

    serviceConfig = LT.serviceHarden // {
      Type = "simple";
      Restart = "always";
      RestartSec = "3";

      Group = "bird";
      User = "bird";
    };
  };

  lantian.nginxVhosts."flapalerted.lantian.pub" = {
    locations = {
      "/" = {
        proxyPass = "http://[::1]:${LT.portStr.FlapAlerted.WebUI}";
      };
    };

    sslCertificate = "lets-encrypt-lantian.pub";
    noIndex.enable = true;
  };
}
