{ pkgs, lib, dns, common, ... }:

with dns;
let
  emailCloudflareRouting = [
    (MX { name = "@"; priority = 7; target = "isaac.mx.cloudflare.net."; })
    (MX { name = "@"; priority = 38; target = "linda.mx.cloudflare.net."; })
    (MX { name = "@"; priority = 14; target = "amir.mx.cloudflare.net."; })
    (TXT { name = "@"; contents = "v=spf1 include:_spf.mx.cloudflare.net ~all"; })
    (TXT { name = "@"; contents = "v=DMARC1; p=none"; })
    (TXT { name = "_dmarc"; contents = "v=DMARC1; p=none"; })
  ];
in
[
  (rec {
    domain = "xuyh0120.win";
    registrar = "doh";
    providers = [ "cloudflare" ];
    records = [
      (common.apexGeoDNS domain)
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

      (CNAME { name = "lab"; target = "lab.lantian.pub."; })
      (CNAME { name = "*"; target = "soyoustart.lantian.pub."; })

      (TXT { name = "@"; contents = "google-site-verification=dFXi0jyD7Qm4WrRUaC79-XQWAJ4UwcdNSbGNTI9IvLg"; })

      (CNAME { name = "s1._domainkey"; target = "s1.domainkey.u6126456.wl207.sendgrid.net."; })
      (CNAME { name = "s2._domainkey"; target = "s2.domainkey.u6126456.wl207.sendgrid.net."; })
      (CNAME { name = "em3816"; target = "u6126456.wl207.sendgrid.net."; })
      (CNAME { name = "url9203"; target = "sendgrid.net."; })
      (CNAME { name = "6126456"; target = "sendgrid.net."; })
    ];
  })
]
