{
  lib,
  LT,
  ...
}:
{
  config.common.records.GeoScriptedServers =
    name:
    let
      baseFilter = n: v: (v.hasTag "server") && (v.hasTag "public-facing");
      greaterChinaFilter = n: v: baseFilter n v && v.hasTag "cn-accel";

      serverArray =
        filter: family:
        lib.concatStringsSep ",\n" (
          lib.flatten (
            lib.mapAttrsToList (
              _: v:
              let
                ip = if family == "A" then v.public.IPv4 else v.public.IPv6;
              in
              lib.optional (ip != null)
                "new Server(${builtins.toJSON ip}, ${v.city.lat}, ${v.city.lng}, 100, Monitoring.getStatus(${builtins.toJSON ip}).isOnline)"
            ) (lib.filterAttrs filter LT.hosts)
          )
        );
    in
    {
      recordType = "BUNNY_DNS_SCRIPT";
      inherit name;
      code = ''
        var globalServers4 = new Array(
          ${serverArray baseFilter "A"}
        );
        var globalServers6 = new Array(
          ${serverArray baseFilter "AAAA"}
        );
        var greaterChinaServers4 = new Array(
          ${serverArray greaterChinaFilter "A"}
        );
        var greaterChinaServers6 = new Array(
          ${serverArray greaterChinaFilter "AAAA"}
        );

        export default function handleQuery(query) {
          var greaterChina = [ "CN", "HK", "MO", "TW" ].indexOf(query.request.geoLocation.country) != -1;
          if (query.request.queryType === "A") {
            var servers = greaterChina ? greaterChinaServers4 : globalServers4;
            return new ARecord(RoutingEngine.getClosestServer(servers, query.request.geoLocation, true).ip, 30);
          } else if (query.request.queryType === "AAAA") {
            var servers = greaterChina ? greaterChinaServers6 : globalServers6;
            return new AaaaRecord(RoutingEngine.getClosestServer(servers, query.request.geoLocation, true).ip, 30);
          }
        }
      '';
    };
}
