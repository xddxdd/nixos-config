{ pkgs, dns, ... }:

with dns;
rec {
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
    (MX { name = "@"; priority = 10; target = "mx1.forwardemail.net."; })
    (MX { name = "@"; priority = 10; target = "mx2.forwardemail.net."; })
    (TXT { name = "@"; contents = "v=DMARC1; p=none"; })
    (TXT { name = "@"; contents = "v=spf1 a mx include:spf.forwardemail.net -all"; })
    (TXT { name = "@"; contents = "yandex-verification: f211240a4ac20462"; })
    (TXT { name = "@"; contents = "forward-email=xuyh0120@gmail.com"; })
    (TXT { name = "_dmarc"; contents = "v=DMARC1; p=none"; })
    (TXT { name = "mail._domainkey"; contents = "v=DKIM1; k=rsa; t=s; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDPEQZwB93q/rldPPECT+ghQEFm2ynfKZlsp3jzarEZ4qas+RQuINk6TmAE/l/q3mcWqr3g/rrmrZJUNsiM0IanlTBGMgG+V5n1KSADVUfuO9Z6LKpVRjRUXT4E/+lu/bBXvuTFVOzAzNC4yviJO2sIEYMfOB0bK2vdVMdKt88IpwIDAQAB"; })
  ];

  externalServices = [
    (ALIAS { name = "@"; target = "hostdare.lantian.pub."; ttl = "10m"; })

    (CNAME { name = "comments"; target = "cname.vercel-dns.com."; })
    (CNAME { name = "ga"; target = "lantian.pub."; cloudflare = true; })
    (CNAME { name = "github-pages"; target = "lantian1998.github.io."; })
    (CNAME { name = "netlify"; target = "lantian.netlify.com."; })
    (CNAME { name = "vercel"; target = "cname.vercel-dns.com."; })
    (TXT { name = "@"; contents = "google-site-verification=eySrj7tImhjLmyEzhvz6-esuzD2jdnQ8anx4qfIwApw"; })

    (A { name = "*.virmach-host"; address = "23.95.217.2"; })
    # (A { name = "virmach-host"; address = "23.95.217.2"; })
    (CNAME { name = "virmach-host"; target = "c792602.tier1.quicns.com."; })

    (NS { name = "xip"; target = "ns-azure.nono.io."; })
    (NS { name = "xip"; target = "ns-gce.nono.io."; })
    (NS { name = "xip"; target = "ns-aws.nono.io."; })
  ];

  internalServices = [
    (CNAME { name = "asf"; target = "soyoustart"; cloudflare = true; })
    (CNAME { name = "bitwarden"; target = "virmach-ny6g"; ttl = "1h"; })
    (CNAME { name = "ci"; target = "soyoustart"; cloudflare = true; })
    (CNAME { name = "ci-github"; target = "soyoustart"; cloudflare = true; })
    (CNAME { name = "cloud"; target = "virmach-ny1g"; cloudflare = true; })
    (CNAME { name = "dashboard"; target = "virmach-ny6g"; ttl = "1h"; })
    (CNAME { name = "git"; target = "virmach-ny1g"; ttl = "1h"; })
    (CNAME { name = "gopher"; target = "hostdare"; ttl = "1h"; })
    (CNAME { name = "irc"; target = "virmach-ny6g"; ttl = "1h"; })
    (CNAME { name = "lab"; target = "virmach-ny1g"; ttl = "1h"; })
    (CNAME { name = "lab-alt"; target = "virmach-ny1g"; cloudflare = true; })
    (CNAME { name = "lg"; target = "virmach-ny6g"; cloudflare = true; })
    (CNAME { name = "login"; target = "virmach-ny6g"; cloudflare = true; })
    (CNAME { name = "pma"; target = "virmach-ny1g"; cloudflare = true; })
    (CNAME { name = "resilio"; target = "soyoustart"; cloudflare = true; })
    (CNAME { name = "vault"; target = "soyoustart"; cloudflare = true; })
    (CNAME { name = "whois"; target = "hostdare"; ttl = "1h"; })
    (CNAME { name = "www"; target = "@"; cloudflare = true; })
  ]
  ++ (serveWithOwnNS "asn")
  ++ [
    (DS { name = "asn"; keytag = 48539; algorithm = 13; digesttype = 2; digest = "7D653B29D41EDF8A607B3119AF7FF3F0C1AE6EBFD19AA6FA1CCF1590E74DE1B6"; ttl = "1d"; })
    (DS { name = "asn"; keytag = 48539; algorithm = 13; digesttype = 4; digest = "0F8035F6A9BF09C806FE665445524632ADFA53E23BFB225E2128963ADAAD5B18294831A345A0AE06FA42E9217DEA0E2A"; ttl = "1d"; })
  ]
  ;
}
