{
  lib,
  LT,
  config,
  ...
}:
let
  ruleType = lib.types.submodule {
    options = {
      priority = lib.mkOption {
        type = lib.types.int;
        default = LT.firewallPriorities.service;
        description = "Rules within a chain are concatenated by ascending priority; equal priorities keep definition order.";
      };
      text = lib.mkOption {
        type = lib.types.lines;
        description = "Raw nftables rule statements, one per line. Consecutive rules sharing a priority may be written as a single multi-line text.";
      };
    };
  };

  dnatType = lib.types.submodule {
    options = {
      priority = lib.mkOption {
        type = lib.types.int;
        default = LT.firewallPriorities.service;
        description = "Priority of this DNAT entry within its chain.";
      };
      matches = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        description = "nftables match expressions, one DNAT rule per expression and target family.";
      };
      ipv4 = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "IPv4 DNAT target, optionally including a port.";
      };
      ipv6 = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "IPv6 DNAT target, optionally including a port.";
      };
    };
  };

  chainType = lib.types.submodule {
    options = {
      type = lib.mkOption {
        type = lib.types.nullOr (
          lib.types.enum [
            "filter"
            "nat"
          ]
        );
        default = null;
        description = "Base chain family; null for regular (jump target) chains.";
      };
      hook = lib.mkOption {
        type = lib.types.nullOr (
          lib.types.enum [
            "input"
            "forward"
            "output"
            "prerouting"
            "postrouting"
          ]
        );
        default = null;
        description = "Netfilter hook of the base chain.";
      };
      priority = lib.mkOption {
        type = lib.types.nullOr lib.types.int;
        default = null;
        description = "Base chain hook priority number.";
      };
      policy = lib.mkOption {
        type = lib.types.enum [
          "accept"
          "drop"
        ];
        default = "accept";
      };
      rules = lib.mkOption {
        type = lib.types.listOf ruleType;
        default = [ ];
        description = "Rules of this chain, concatenated by ascending priority.";
      };
      dnat = lib.mkOption {
        type = lib.types.listOf dnatType;
        default = [ ];
        description = "Structured DNAT entries of this chain, sorted together with rules by priority.";
      };
    };
  };

  ipsetType = lib.types.submodule {
    options = {
      type = lib.mkOption {
        type = lib.types.enum [
          "ipv4_addr"
          "ipv6_addr"
          "inet_service"
          "ifname"
        ];
        description = "nftables set data type.";
      };
      flags = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "constant" ];
        description = "nftables set flags.";
      };
      elements = lib.mkOption {
        type = lib.types.listOf (lib.types.either lib.types.int lib.types.str);
        default = [ ];
        description = "nftables set elements.";
      };
    };
  };

  renderSet =
    name: s:
    lib.concatStringsSep "\n" (
      [
        "set ${name} {"
        "type ${s.type}"
        "flags ${lib.concatStringsSep ", " s.flags}"
      ]
      ++ lib.optional (
        s.elements != [ ]
      ) "elements = { ${lib.concatStringsSep ", " (map builtins.toString s.elements)} }"
      ++ [ "}" ]
    );

  renderChain =
    name: c:
    let
      lines =
        (lib.optionals (c.type != null) [
          "type ${c.type} hook ${c.hook} priority ${builtins.toString c.priority}; policy ${c.policy};"
        ])
        ++ (lib.filter (line: line != "") (
          lib.concatMap (rule: map lib.trim (lib.splitString "\n" rule.text)) (
            lib.sort (a: b: a.priority < b.priority) (
              c.rules
              ++ map (entry: {
                inherit (entry) priority;
                text = lib.concatStringsSep "\n" (
                  (lib.optionals (entry.ipv4 != null) (
                    map (match: "${lib.trim match} dnat ip to ${entry.ipv4}") entry.matches
                  ))
                  ++ (lib.optionals (entry.ipv6 != null) (
                    map (match: "${lib.trim match} dnat ip6 to ${entry.ipv6}") entry.matches
                  ))
                );
              }) c.dnat
            )
          )
        ));
    in
    lib.concatStringsSep "\n" ([ "chain ${name} {" ] ++ lines ++ [ "}" ]);
in
{
  options.lantian.firewall = {
    chains = lib.mkOption {
      type = lib.types.attrsOf chainType;
      default = { };
      description = "nftables chains of the lantian firewall table.";
    };

    ipsets = lib.mkOption {
      type = lib.types.attrsOf ipsetType;
      default = { };
      description = "nftables sets of the lantian firewall table.";
    };

    presets = lib.mkOption {
      type = lib.types.submodule { };
      default = { };
      description = "Firewall feature presets; each preset declares an `enable` option plus its own tuning options, implemented by the module that owns the feature.";
    };
  };

  config = {
    lantian.firewall.chains = {
      FILTER_INPUT = {
        type = "filter";
        hook = "input";
        priority = 5;
      };
      FILTER_FORWARD = {
        type = "filter";
        hook = "forward";
        priority = 5;
      };
      FILTER_OUTPUT = {
        type = "filter";
        hook = "output";
        priority = 5;
      };
      NAT_PREROUTING = {
        type = "nat";
        hook = "prerouting";
        priority = -95;
      };
      NAT_INPUT = {
        type = "nat";
        hook = "input";
        priority = 105;
      };
      NAT_OUTPUT = {
        type = "nat";
        hook = "output";
        priority = -95;
      };
      NAT_POSTROUTING = {
        type = "nat";
        hook = "postrouting";
        priority = 105;
      };
    };

    lantian.firewall.chains.FILTER_FORWARD.rules = [
      {
        priority = LT.firewallPriorities.early;
        text = "tcp flags syn tcp option maxseg size set rt mtu";
      }
      {
        priority = LT.firewallPriorities.preService;
        text = ''
          ct state { established, related } accept
          ct status dnat accept
        '';
      }
    ];

    lantian.firewall.ipsets = {
      RESERVED_IPV4 = {
        type = "ipv4_addr";
        flags = [
          "constant"
          "interval"
        ];
        elements = LT.constants.reserved.IPv4;
      };
      RESERVED_IPV6 = {
        type = "ipv6_addr";
        flags = [
          "constant"
          "interval"
        ];
        elements = LT.constants.reserved.IPv6;
      };
    };

    networking.nftables = {
      enable = true;
      tables.lantian = {
        family = "inet";
        content =
          let
            chainBlocks = lib.mapAttrsToList renderChain config.lantian.firewall.chains;
            setBlocks = lib.mapAttrsToList renderSet config.lantian.firewall.ipsets;
          in
          lib.concatStringsSep "\n" (chainBlocks ++ setBlocks);
      };
    };
  };
}
