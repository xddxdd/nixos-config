{ pkgs, dns, common, ... }:

with dns;
[
  (rec {
    domain = "xuyh0120.win";
    providers = [ "cloudflare" ];
    records = [
      (common.apexGeoDNS domain)
      common.hostRecs.CAA
      (common.hostRecs.Normal domain)
      (common.hostRecs.SSHFP domain)
      common.records.ForwardEmail

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
