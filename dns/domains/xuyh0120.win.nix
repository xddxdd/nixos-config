{ pkgs, lib, dns, common, hosts, ... }:

with dns;
let
  inherit (common.hostRecs) hasPublicIP;

  emailCloudflareRouting = [
    (MX { name = "@"; priority = 7; target = "isaac.mx.cloudflare.net."; })
    (MX { name = "@"; priority = 38; target = "linda.mx.cloudflare.net."; })
    (MX { name = "@"; priority = 14; target = "amir.mx.cloudflare.net."; })
    (TXT { name = "@"; contents = "v=spf1 include:_spf.mx.cloudflare.net ~all"; })
    (TXT { name = "@"; contents = "v=DMARC1; p=none"; })
    (TXT { name = "_dmarc"; contents = "v=DMARC1; p=none"; })
  ];

  externalServices = [
    (TXT { name = "@"; contents = "google-site-verification=dFXi0jyD7Qm4WrRUaC79-XQWAJ4UwcdNSbGNTI9IvLg"; })

    (CNAME { name = "s1._domainkey"; target = "s1.domainkey.u6126456.wl207.sendgrid.net."; })
    (CNAME { name = "s2._domainkey"; target = "s2.domainkey.u6126456.wl207.sendgrid.net."; })
    (CNAME { name = "em3816"; target = "u6126456.wl207.sendgrid.net."; })
    (CNAME { name = "url9203"; target = "sendgrid.net."; })
    (CNAME { name = "6126456"; target = "sendgrid.net."; })
  ];

  internalServices = [
    (CNAME { name = "asf"; target = "soyoustart"; ttl = "1h"; })
    (CNAME { name = "books"; target = "soyoustart"; ttl = "1h"; })
    (CNAME { name = "bitwarden"; target = "soyoustart"; ttl = "1h"; })
    (CNAME { name = "cloud"; target = "soyoustart"; ttl = "1h"; })
    (CNAME { name = "dashboard"; target = "soyoustart"; ttl = "1h"; })
    (CNAME { name = "jellyfin"; target = "lantian-lenovo"; ttl = "1h"; })
    (CNAME { name = "lab"; target = "lab.lantian.pub."; ttl = "1h"; })
    (CNAME { name = "login"; target = "soyoustart"; ttl = "1h"; })
    (CNAME { name = "minio"; target = "soyoustart"; ttl = "1h"; })
    (CNAME { name = "pga"; target = "soyoustart"; ttl = "1h"; })
    (CNAME { name = "rss"; target = "soyoustart"; ttl = "1h"; })
    (CNAME { name = "s3"; target = "soyoustart"; ttl = "1h"; })
    (CNAME { name = "stats"; target = "soyoustart"; ttl = "1h"; })
    (CNAME { name = "vault"; target = "soyoustart"; ttl = "1h"; })

    # Services with independent instances on numerous nodes
    (lib.mapAttrsToList
      (n: v: [
        (CNAME { name = "pma-${n}"; target = n; cloudflare = hasPublicIP v; })
        (CNAME { name = "resilio-${n}"; target = n; cloudflare = hasPublicIP v; })
      ])
      hosts)
  ];
in
[
  rec {
    domain = "xuyh0120.win";
    registrar = "doh";
    providers = [ "cloudflare" ];
    records = [
      (dns.ALIAS { name = "${domain}."; target = common.records.GeoDNSTarget; ttl = "10m"; })
      (dns.CNAME { name = "www.${domain}."; target = "${domain}."; cloudflare = true; })

      common.hostRecs.CAA
      (common.hostRecs.Normal domain)
      (common.hostRecs.SSHFP domain)
      emailCloudflareRouting
      (TXT { name = "_token._dnswl"; contents = "qcq5l789ndevk0jawrgcah0f5s4ld8sz"; })
      common.records.Libravatar

      (common.hostRecs.LTNet "ltnet.${domain}")
      (common.hostRecs.DN42 "dn42.${domain}")
      (common.hostRecs.NeoNetwork "neo.${domain}")
      (common.hostRecs.Yggdrasil "ygg.${domain}")

      externalServices
      internalServices
    ];
  }
]
