{
  pkgs,
  lib,
  dns,
  common,
  hosts,
  ...
}:
with dns; let
  externalServices = [
    (TXT {
      name = "@";
      contents = "google-site-verification=dFXi0jyD7Qm4WrRUaC79-XQWAJ4UwcdNSbGNTI9IvLg";
    })

    (CNAME {
      name = "s1._domainkey";
      target = "s1.domainkey.u6126456.wl207.sendgrid.net.";
    })
    (CNAME {
      name = "s2._domainkey";
      target = "s2.domainkey.u6126456.wl207.sendgrid.net.";
    })
    (CNAME {
      name = "em3816";
      target = "u6126456.wl207.sendgrid.net.";
    })
    (CNAME {
      name = "url9203";
      target = "sendgrid.net.";
    })
    (CNAME {
      name = "6126456";
      target = "sendgrid.net.";
    })
  ];

  internalServices = [
    (CNAME {
      name = "alert";
      target = "v-ps-fal";
      ttl = "1h";
    })
    (CNAME {
      name = "asf";
      target = "terrahost";
      ttl = "1h";
    })
    (CNAME {
      name = "attic";
      target = "v-ps-fal";
      ttl = "1h";
    })
    (CNAME {
      name = "books";
      target = "v-ps-fal";
      ttl = "1h";
    })
    (CNAME {
      name = "bitwarden";
      target = "v-ps-fal";
      ttl = "1h";
    })
    (CNAME {
      name = "cloud";
      target = "v-ps-fal";
      ttl = "1h";
    })
    (CNAME {
      name = "dashboard";
      target = "v-ps-fal";
      ttl = "1h";
    })
    (CNAME {
      name = "jellyfin";
      target = "lt-home-vm.ltnet.xuyh0120.win.";
      ttl = "1h";
    })
    (CNAME {
      name = "lab";
      target = "lab.lantian.pub.";
      ttl = "1h";
    })
    (CNAME {
      name = "netbox";
      target = "v-ps-fal";
      ttl = "1h";
    })
    (CNAME {
      name = "private";
      target = "v-ps-fal.ltnet.xuyh0120.win.";
      ttl = "1h";
    })
    (CNAME {
      name = "prometheus";
      target = "v-ps-fal";
      ttl = "1h";
    })
    (CNAME {
      name = "pterodactyl";
      target = "lt-home-vm.ltnet.xuyh0120.win.";
      ttl = "1h";
    })
    (CNAME {
      name = "rss";
      target = "v-ps-fal";
      ttl = "1h";
    })
    (CNAME {
      name = "rsshub";
      target = "v-ps-fal.ltnet.xuyh0120.win.";
      ttl = "1h";
    })
    (CNAME {
      name = "stats";
      target = "v-ps-fal";
      ttl = "1h";
    })
    (CNAME {
      name = "tachidesk";
      target = "lt-home-vm.ltnet.xuyh0120.win.";
      ttl = "1h";
    })
  ];
in [
  rec {
    domain = "xuyh0120.win";
    registrar = "porkbun";
    providers = ["cloudflare"];
    records = [
      (ALIAS {
        name = "${domain}.";
        target = common.records.GeoDNSTarget;
        ttl = "10m";
      })
      (CNAME {
        name = "www.${domain}.";
        target = common.records.GeoDNSTarget;
        ttl = "10m";
      })

      common.hostRecs.CAA
      (common.hostRecs.Normal domain)
      (common.hostRecs.SSHFP domain)
      (common.records.Autoconfig domain)
      common.records.MXRoute
      (TXT {
        name = "_token._dnswl";
        contents = "qcq5l789ndevk0jawrgcah0f5s4ld8sz";
      })
      common.records.Libravatar
      common.records.ProxmoxCluster
      common.records.SIP
      common.records.GeoRecords
      (common.hostRecs.LTNet "ltnet.${domain}")
      (common.hostRecs.DN42 "dn42.${domain}")
      (common.hostRecs.NeoNetwork "neo.${domain}")

      externalServices
      internalServices
    ];
  }
]
