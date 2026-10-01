{
  config,
  lib,
  LT,
  ...
}:
let
  # Old host names that have been replaced by the current host
  replacedOnThisHost = lib.filterAttrs (
    _: newName: newName == config.networking.hostName
  ) LT.replacedHosts;
in
{
  lantian.nginxVhosts = lib.mapAttrs' (
    old: new:
    let
      domain = "${old}.xuyh0120.win";
    in
    {
      name = "*.${domain}";
      value = {
        # Regex server_name captures the subdomain label, so the redirect
        # can move it onto the new host's name
        serverName = "~^(?<sub>[^.]+)\\.${lib.escapeRegex domain}$";
        locations."/".return = "301 https://$sub.${new}.xuyh0120.win$request_uri";
        enableCommonLocationOptions = false;
        sslCertificate = "zerossl-${old}.xuyh0120.win";
      };
    }
  ) replacedOnThisHost;
}
