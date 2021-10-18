{ config, pkgs, ... }:

let
  hosts = import ../../hosts.nix;
  thisHost = builtins.getAttr config.networking.hostName hosts;
  hostPkgs = pkgs;
  hostConfig = config;
  containerIP = 53;
in
{
  containers.powerdns-recursor = {
    autoStart = true;
    ephemeral = true;

    bindMounts = {
      "/var/lib" = { hostPath = "/var/lib"; isReadOnly = false; };
    };

    privateNetwork = true;
    hostBridge = "ltnet";
    localAddress = "${thisHost.ltnet.IPv4Prefix}.${builtins.toString containerIP}/24";
    localAddress6 = "${thisHost.ltnet.IPv6Prefix}::${builtins.toString containerIP}/64";

    config = { config, pkgs, ... }: {
      system.stateVersion = "21.05";
      nixpkgs.pkgs = hostPkgs;
      networking.hostName = hostConfig.networking.hostName;
      networking.defaultGateway = "${thisHost.ltnet.IPv4Prefix}.1";
      networking.defaultGateway6 = "${thisHost.ltnet.IPv6Prefix}::1";
      networking.firewall.enable = false;
      services.journald.extraConfig = ''
        SystemMaxUse=50M
        SystemMaxFileSize=10M
      '';

      services.pdns-recursor = {
        enable = true;
        dns.address = "0.0.0.0, ::";
        dns.allowFrom = [ "0.0.0.0/0" "::/0" ];
        forwardZones = {
          # DN42
          "dn42" = "172.22.76.109;fdbc:f9dc:67ad:2547::54";
          "10.in-addr.arpa" = "172.22.76.109;fdbc:f9dc:67ad:2547::54";
          "20.172.in-addr.arpa" = "172.22.76.109;fdbc:f9dc:67ad:2547::54";
          "21.172.in-addr.arpa" = "172.22.76.109;fdbc:f9dc:67ad:2547::54";
          "22.172.in-addr.arpa" = "172.22.76.109;fdbc:f9dc:67ad:2547::54";
          "23.172.in-addr.arpa" = "172.22.76.109;fdbc:f9dc:67ad:2547::54";
          "31.172.in-addr.arpa" = "172.22.76.109;fdbc:f9dc:67ad:2547::54";
          "d.f.ip6.arpa" = "172.22.76.109;fdbc:f9dc:67ad:2547::54";
          "hack" = "172.31.0.5";
          "rzl" = "172.22.36.250";

          # OpenNIC & FurNIC
          "bbs" = "172.22.76.109;fdbc:f9dc:67ad:2547::54";
          "chan" = "172.22.76.109;fdbc:f9dc:67ad:2547::54";
          "cyb" = "172.22.76.109;fdbc:f9dc:67ad:2547::54";
          "dns.opennic.glue" = "172.22.76.109;fdbc:f9dc:67ad:2547::54";
          "dyn" = "172.22.76.109;fdbc:f9dc:67ad:2547::54";
          "epic" = "172.22.76.109;fdbc:f9dc:67ad:2547::54";
          "fur" = "172.22.76.109;fdbc:f9dc:67ad:2547::54";
          "geek" = "172.22.76.109;fdbc:f9dc:67ad:2547::54";
          "gopher" = "172.22.76.109;fdbc:f9dc:67ad:2547::54";
          "indy" = "172.22.76.109;fdbc:f9dc:67ad:2547::54";
          "libre" = "172.22.76.109;fdbc:f9dc:67ad:2547::54";
          #"neo" = "172.22.76.109;fdbc:f9dc:67ad:2547::54";
          "null" = "172.22.76.109;fdbc:f9dc:67ad:2547::54";
          "o" = "172.22.76.109;fdbc:f9dc:67ad:2547::54";
          "opennic.glue" = "172.22.76.109;fdbc:f9dc:67ad:2547::54";
          "oss" = "172.22.76.109;fdbc:f9dc:67ad:2547::54";
          "oz" = "172.22.76.109;fdbc:f9dc:67ad:2547::54";
          "parody" = "172.22.76.109;fdbc:f9dc:67ad:2547::54";
          "pirate" = "172.22.76.109;fdbc:f9dc:67ad:2547::54";

          # Emercoin
          "bazar" = "185.122.58.37;2a06:8ec0:3::1:2c4e;172.106.88.242;2602:ffc5:30::1:5c47";
          "coin" = "185.122.58.37;2a06:8ec0:3::1:2c4e;172.106.88.242;2602:ffc5:30::1:5c47";
          "emc" = "185.122.58.37;2a06:8ec0:3::1:2c4e;172.106.88.242;2602:ffc5:30::1:5c47";
          "lib" = "185.122.58.37;2a06:8ec0:3::1:2c4e;172.106.88.242;2602:ffc5:30::1:5c47";
        };
        luaConfig = ''
          addNTA("bbs")
          addNTA("chan")
          addNTA("cyb")
          addNTA("dns.opennic.glue")
          addNTA("dyn")
          addNTA("epic")
          addNTA("fur")
          addNTA("geek")
          addNTA("gopher")
          addNTA("indy")
          addNTA("libre")
          -- addNTA("neo")
          addNTA("null")
          addNTA("o")
          addNTA("opennic.glue")
          addNTA("oss")
          addNTA("oz")
          addNTA("parody")
          addNTA("pirate")

          -- Special DNS zone not handled by ltnet-scripts
          addNTA("rzl")

          -- Internal zones where DNSSEC will fail
          addNTA("lantian.dn42")
          addNTA("d.a.7.6.c.d.9.f.c.b.d.f.ip6.arpa")
          addNTA("lantian.neo")
          addNTA("10.127.10.in-addr.arpa")
          addNTA("0.1.0.0.7.2.1.0.0.1.d.f.ip6.arpa")
          addNTA("18.172.in-addr.arpa")

          dofile("/var/lib/powerdns-recursor/fwd-dn42-interconnect.lua")
        '';
        serveRFC1918 = false;
        settings = {
          any-to-tcp = "yes";
          dont-query = "";
          qname-minimization = "no";
          query-local-address = "${thisHost.ltnet.IPv4Prefix}.${builtins.toString containerIP}, ${thisHost.ltnet.IPv6Prefix}::${builtins.toString containerIP}";
          reuseport = "yes";
          server-id = "lantian";
          tcp-fast-open = "128";
          include-dir = "/var/lib/powerdns-recursor";
          "forward-zones-recurse+" = ".=172.22.76.109:55;[fdbc:f9dc:67ad:2547::54]:55";
        };
      };

      services.bird2 = {
        enable = true;
        checkConfig = false;
        config = ''
          log stderr { error, fatal };
          protocol device {}

          protocol ospf {
            ipv4 {
              import none;
              export all;
            };
            area 0.0.0.0 {
              interface "*" {
                type broadcast;
                cost 1;
                hello 2;
                retransmit 2;
                dead count 2;
              };
            };
          }

          protocol ospf v3 {
            ipv6 {
              import none;
              export all;
            };
            area 0.0.0.0 {
              interface "*" {
                type broadcast;
                cost 1;
                hello 2;
                retransmit 2;
                dead count 2;
              };
            };
          }

          protocol static {
            ipv4;
            route 172.22.76.110/32 unreachable;
            route 172.18.0.253/32 unreachable;
            route 10.127.10.253/32 unreachable;
          }

          protocol static {
            ipv6;
            route fdbc:f9dc:67ad:2547::53/128 unreachable;
            route fd10:127:10:2547::53/128 unreachable;
          }
        '';
      };

      services.resolved.enable = false;

      systemd.network.enable = true;
      systemd.network.netdevs.dummy0 = {
        netdevConfig = {
          Kind = "dummy";
          Name = "dummy0";
        };
      };

      systemd.network.networks.dummy0 = {
        matchConfig = {
          Name = "dummy0";
        };

        networkConfig = {
          IPv6PrivacyExtensions = false;
        };

        addresses = [
          { addressConfig = { Address = "172.22.76.110/32"; }; }
          { addressConfig = { Address = "172.18.0.253/32"; }; }
          { addressConfig = { Address = "10.127.10.253/32"; }; }
          { addressConfig = { Address = "fdbc:f9dc:67ad:2547::53/128"; }; }
          { addressConfig = { Address = "fd10:127:10:2547::53/128"; }; }
        ];
      };
    };
  };
}
