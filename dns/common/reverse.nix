{ config, lib, ... }:
{
  common.reverse6 =
    { prefix, target }:
    let
      prefixSplitted = lib.splitString "/" prefix;
      prefixIP = lib.head prefixSplitted;
    in
    rec {
      domain = prefix;
      reverse = true;
      registrar = "none";
      providers = [ "henet" ];
      records = lib.flatten [
        {
          recordType = "PTR";
          name = "*";
          inherit target;
        }
        {
          recordType = "PTR";
          name = "${prefixIP}1";
          inherit target;
        }
        (config.common.manosaba true "${prefixIP}" 2)
      ];
    };
}
