{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
}@args:
let
  bgpNodeOptions =
    { name, config, ... }:
    {
      options = {
        name = lib.mkOption {
          type = lib.types.str;
          description = "Name of this graph node";
        };

        id = lib.mkOption {
          type = lib.types.int;
          description = "Index of this graph node";
        };
      };
    };

  bgpEdgeOptions =
    { name, config, ... }:
    {
      options = {
        fromId = lib.mkOption {
          type = lib.types.int;
          description = "Edge starts from node with this ID";
        };

        toId = lib.mkOption {
          type = lib.types.int;
          description = "Edge ends on node with this ID";
        };

        distance = lib.mkOption {
          type = lib.types.int;
          default = 1;
          description = "Distance, used to calculate cost";
        };
      };
    };

  bgpGraphOptions =
    { name, config, ... }:
    {
      options = {
        baseAsn = lib.mkOption {
          type = lib.types.int;
          description = "Base ASN used in the network";
        };
        baseCidr = lib.mkOption {
          type = lib.types.str;
          description = "Base IPv6 address used in the network";
        };
        nodes = lib.mkOption {
          type = lib.types.listOf (lib.types.submodule bgpNodeOptions);
          description = "BGP graph nodes";
        };
        edges = lib.mkOption {
          type = lib.types.listOf (lib.types.submodule bgpEdgeOptions);
          description = "BGP graph edges";
        };

        nodeIdMap = lib.mkOption {
          readOnly = true;
          default = builtins.listToAttrs (
            builtins.map (node: {
              name = builtins.toString node.id;
              value = node;
            }) config.nodes
          );
        };
      };
    };
in
{
  options = {
    lantian.bgp-graph = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule bgpGraphOptions);
      default = { };
      description = "BGP mapping instances";
    };
  };

  imports = [
    ./bird.nix
    ./edges.nix
    ./nodes.nix
    ./starter.nix
  ];
}
