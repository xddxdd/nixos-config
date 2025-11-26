{ config, lib, ... }:
{
  networking.hosts."127.0.0.1" = builtins.filter (lib.hasInfix ".") (
    (builtins.attrNames config.lantian.nginxVhosts)
    ++ (builtins.concatLists (
      lib.mapAttrsToList (k: v: v.serverAliases or [ ]) config.lantian.nginxVhosts
    ))
  );
}
