{
  config,
  lib,
  LT,
  ...
}:
{
  networking.hosts."${LT.this.ltnet.IPv4}" = builtins.filter (lib.hasInfix ".") (
    (builtins.attrNames config.lantian.nginxVhosts)
    ++ (builtins.concatLists (
      lib.mapAttrsToList (k: v: v.serverAliases or [ ]) config.lantian.nginxVhosts
    ))
  );
}
