{
  lib,
  LT,
  ...
}:
{
  # Scripted GeoDNS record routing to the closest online server. Replaces Bunny's
  # GEO record so greater-China requesters can be routed to cn-accel nodes via a
  # different server pool than the rest of the world.
  config.common.records.GeoScriptedServers =
    name:
    let
      baseFilter = n: v: (v.hasTag "server") && (v.hasTag "public-facing");
      # Greater China gets the closest server among cn-accel nodes; other
      # regions must NOT filter on cn-accel, hence two pools per family.
      greaterChinaFilter = n: v: baseFilter n v && v.hasTag "cn-accel";

      # Bunny limits: Monitoring/RoutingEngine helpers fail outright on IPv6
      # addresses, so the RoutingEngine-based getClosestServer is only usable
      # for IPv4. Both families use custom selection logic (see selectServer).
      serverArray =
        filter: family:
        lib.concatStringsSep ",\n" (
          lib.flatten (
            lib.mapAttrsToList (
              _: v:
              let
                ip = if family == "A" then v.public.IPv4 else v.public.IPv6;
              in
              lib.optional (ip != null) "new Server(${builtins.toJSON ip}, ${v.city.lat}, ${v.city.lng})"
            ) (lib.filterAttrs filter LT.hosts)
          )
        );
    in
    {
      recordType = "BUNNY_DNS_SCRIPT";
      inherit name;
      # Only selectServer may call Monitoring (healthcheck), so offline server
      # filtering stays in one place. withHealthcheck is only true for IPv4:
      # Monitoring.getStatus fails on IPv6 addresses, so IPv6 queries must not
      # touch it and are assumed fully online. IPv6 hosts at the same location
      # tie on distance and are picked randomly.
      code = ''
        var globalServers4 = [
          ${serverArray baseFilter "A"}
        ];
        var globalServers6 = [
          ${serverArray baseFilter "AAAA"}
        ];
        var greaterChinaServers4 = [
          ${serverArray greaterChinaFilter "A"}
        ];
        var greaterChinaServers6 = [
          ${serverArray greaterChinaFilter "AAAA"}
        ];

        function selectServer(servers, location, withHealthcheck) {
          var closest = [ ];
          var minDistance = -1;
          for (var i = 0; i < servers.length; i++) {
            if (withHealthcheck && !Monitoring.getStatus(servers[i].ip).isOnline) {
              continue;
            }
            var distance = GeoDistance.calculate(servers[i], location);
            if (minDistance == -1 || distance < minDistance) {
              minDistance = distance;
              closest = [ servers[i] ];
            } else if (distance == minDistance) {
              closest.push(servers[i]);
            }
          }
          return closest[Math.floor(Math.random() * closest.length)];
        }

        export default function handleQuery(query) {
          var greaterChina = [ "CN", "HK", "MO", "TW" ].indexOf(query.request.geoLocation.country) != -1;
          if (query.request.queryType === "A") {
            var servers = greaterChina ? greaterChinaServers4 : globalServers4;
            return new ARecord(selectServer(servers, query.request.geoLocation, true).ip, 30);
          } else if (query.request.queryType === "AAAA") {
            var servers = greaterChina ? greaterChinaServers6 : globalServers6;
            return new AaaaRecord(selectServer(servers, query.request.geoLocation, false).ip, 30);
          }
        }
      '';
    };
}
