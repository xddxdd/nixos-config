{
  pkgs,
  LT,
  ...
}:
let
  inherit (pkgs.nur-xddxdd) flapalerted;
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
        --bgpListenAddress [${LT.this.ltnet.IPv6}]:${LT.portStr.FlapAlerted.BGP} \
        --httpAPIListenAddress [::1]:${LT.portStr.FlapAlerted.WebUI} \
        -routeChangeCounter 120 \
        -overThresholdTarget 5 \
        -underThresholdTarget 30
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

    sslCertificate = "zerossl-lantian.pub";
    noIndex.enable = true;
  };
}
