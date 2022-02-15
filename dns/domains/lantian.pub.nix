{ pkgs, dns, common, ... }:

with dns;
let
  serveWithOwnNS = name: [
    (NS { inherit name; target = "50kvm.lantian.pub."; })
    (NS { inherit name; target = "hostdare.lantian.pub."; })
    (NS { inherit name; target = "virmach-ny1g.lantian.pub."; })
    (NS { inherit name; target = "buyvm.lantian.pub."; })
    (NS { inherit name; target = "soyoustart.lantian.pub."; })
  ];

  email = [
    (CNAME { name = "s1._domainkey"; target = "s1.domainkey.u6126456.wl207.sendgrid.net."; })
    (CNAME { name = "s2._domainkey"; target = "s2.domainkey.u6126456.wl207.sendgrid.net."; })
    (CNAME { name = "em1411"; target = "u6126456.wl207.sendgrid.net."; })
    (CNAME { name = "url3735"; target = "sendgrid.net."; })
    (CNAME { name = "6126456"; target = "sendgrid.net."; })
    (TXT { name = "@"; contents = "yandex-verification: f211240a4ac20462"; })
    (TXT { name = "mail._domainkey"; contents = "v=DKIM1; k=rsa; t=s; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDPEQZwB93q/rldPPECT+ghQEFm2ynfKZlsp3jzarEZ4qas+RQuINk6TmAE/l/q3mcWqr3g/rrmrZJUNsiM0IanlTBGMgG+V5n1KSADVUfuO9Z6LKpVRjRUXT4E/+lu/bBXvuTFVOzAzNC4yviJO2sIEYMfOB0bK2vdVMdKt88IpwIDAQAB"; })
  ];

  emailCloudflareRouting = [
    (MX { name = "@"; priority = 11; target = "isaac.mx.cloudflare.net."; })
    (MX { name = "@"; priority = 81; target = "linda.mx.cloudflare.net."; })
    (MX { name = "@"; priority = 29; target = "amir.mx.cloudflare.net."; })
    (TXT { name = "@"; contents = "v=spf1 include:_spf.mx.cloudflare.net ~all"; })
    (TXT { name = "@"; contents = "v=DMARC1; p=none"; })
    (TXT { name = "_dmarc"; contents = "v=DMARC1; p=none"; })
  ];

  externalServices = [
    (CNAME { name = "backblaze"; target = "f002.backblazeb2.com."; cloudflare = true; })
    (CNAME { name = "comments"; target = "cname.vercel-dns.com."; })
    (CNAME { name = "ga"; target = "lantian.pub."; cloudflare = true; })
    (CNAME { name = "gcore"; target = "cl-47f440a2.gcdn.co."; })
    (CNAME { name = "github-pages"; target = "lantian1998.github.io."; })
    (CNAME { name = "netlify"; target = "lantian.netlify.com."; })
    (A { name = "oracle-lb"; address = "140.238.39.120"; })
    (AAAA { name = "oracle-lb"; address = "2603:c021:8000:aaaa:c15d:d2e2:da2d:af58"; })
    (CNAME { name = "render"; target = "lantian1998.onrender.com."; })

    # Freshping & verification
    (CNAME { name = "status"; target = "statuspage.freshping.io."; cloudflare = true; })
    (CNAME { name = "737acf9b9d41aae168dbe658b5efada5cab2c445.status"; target = "667076964ffd2f999aa14ff100c5467dbaee91a0.fpverify.freshping.io."; })

    (CNAME { name = "vercel"; target = "cname.vercel-dns.com."; })
    (TXT { name = "@"; contents = "google-site-verification=eySrj7tImhjLmyEzhvz6-esuzD2jdnQ8anx4qfIwApw"; })

    (A { name = "*.virmach-host"; address = "23.95.217.2"; })
    # (A { name = "virmach-host"; address = "23.95.217.2"; })
    (CNAME { name = "virmach-host"; target = "c792602.tier1.quicns.com."; })
  ];

  internalServices = [
    (CNAME { name = "asf"; target = "soyoustart"; cloudflare = true; })
    (CNAME { name = "bitwarden"; target = "virmach-ny6g"; ttl = "1h"; })
    (CNAME { name = "buypass-ssl"; target = "soyoustart"; ttl = "1h"; })
    (CNAME { name = "ci"; target = "soyoustart"; cloudflare = true; })
    (CNAME { name = "ci-github"; target = "soyoustart"; cloudflare = true; })
    (CNAME { name = "cloud"; target = "virmach-ny6g"; cloudflare = true; })
    (CNAME { name = "dashboard"; target = "virmach-ny6g"; ttl = "1h"; })
    (CNAME { name = "git"; target = "virmach-ny6g"; ttl = "1h"; })
    (CNAME { name = "gopher"; target = "hostdare"; ttl = "1h"; })
    (CNAME { name = "lab"; target = "virmach-ny6g"; ttl = "1h"; })
    (CNAME { name = "lg"; target = "virmach-ny6g"; cloudflare = true; })
    (CNAME { name = "login"; target = "virmach-ny6g"; cloudflare = true; })
    (CNAME { name = "pga"; target = "virmach-ny6g"; cloudflare = true; })
    (CNAME { name = "pma"; target = "virmach-ny6g"; cloudflare = true; })
    (CNAME { name = "resilio-oracle-vm-arm"; target = "oracle-vm-arm"; cloudflare = true; })
    (CNAME { name = "resilio-soyoustart"; target = "soyoustart"; cloudflare = true; })
    (CNAME { name = "resilio-virmach-ny6g"; target = "virmach-ny6g"; cloudflare = true; })
    (CNAME { name = "rss"; target = "virmach-ny6g"; ttl = "1h"; })
    (CNAME { name = "vault"; target = "soyoustart"; cloudflare = true; })
    (CNAME { name = "whois"; target = "hostdare"; ttl = "1h"; })
    (CNAME { name = "www"; target = "@"; cloudflare = true; })
    (CNAME { name = "zerossl"; target = "soyoustart"; ttl = "1h"; })
  ]
  ++ (serveWithOwnNS "asn")
  ++ [
    (DS { name = "asn"; keytag = 48539; algorithm = 13; digesttype = 2; digest = "7D653B29D41EDF8A607B3119AF7FF3F0C1AE6EBFD19AA6FA1CCF1590E74DE1B6"; ttl = "1d"; })
    (DS { name = "asn"; keytag = 48539; algorithm = 13; digesttype = 4; digest = "0F8035F6A9BF09C806FE665445524632ADFA53E23BFB225E2128963ADAAD5B18294831A345A0AE06FA42E9217DEA0E2A"; ttl = "1d"; })
  ]
  ;
in
[
  (rec {
    domain = "lantian.pub";
    registrar = "doh";
    providers = [ "cloudflare" ];
    records = [
      (common.apexGeoDNS domain)
      common.hostRecs.CAA
      (common.hostRecs.Normal domain)
      (common.hostRecs.SSHFP domain)
      (common.hostRecs.TXT domain)
      emailCloudflareRouting
      (TXT { name = "_token._dnswl"; contents = "xdyg6y366ui8ihelglmjjtxhtpd7rivm"; })

      (common.hostRecs.LTNet "zt.${domain}")
      (common.hostRecs.DN42 "dn42.${domain}")
      (common.hostRecs.NeoNetwork "neo.${domain}")

      email
      externalServices
      internalServices
    ];
  })
]
