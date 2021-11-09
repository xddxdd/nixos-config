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
    (CNAME { name = "_dnslink.ipfs"; target = "_dnslink.ipfs.xuyh0120.win."; ttl = "10m"; })
    (CNAME { name = "_dnslink"; target = "_dnslink.ipfs.xuyh0120.win."; ttl = "10m"; })
    (CNAME { name = "github-pages"; target = "lantian1998.github.io."; })
    (CNAME { name = "ipfs"; target = "cloudflare-ipfs.com."; })
    (CNAME { name = "netlify"; target = "lantian.netlify.com."; })
    (CNAME { name = "vercel"; target = "cname.vercel-dns.com."; })
    (TXT { name = "@"; contents = "google-site-verification=eySrj7tImhjLmyEzhvz6-esuzD2jdnQ8anx4qfIwApw"; })

    (A { name = "*.virmach-host"; address = "23.95.217.2"; })
    # (A { name = "virmach-host"; address = "23.95.217.2"; })
    (CNAME { name = "virmach-host"; target = "c792602.tier1.quicns.com."; })

    (A { name = "kubesail"; address = "13.52.195.86"; })
    (A { name = "kubesail"; address = "52.9.155.56"; })
    (A { name = "*.kubesail"; address = "13.52.195.86"; })
    (A { name = "*.kubesail"; address = "52.9.155.56"; })
    (TXT { name = "kubesail"; contents = "KUBESAIL_VERIFY=329f4d6d-d6b8-4c30-b240-798bff13a916"; })

    (CNAME { name = "home"; target = "xuyh0120.f3322.org."; })

    (NS { name = "xip"; target = "ns-vultr.nono.io."; })
    (NS { name = "xip"; target = "ns-azure.nono.io."; })
    (NS { name = "xip"; target = "ns-gce.nono.io."; })
    (NS { name = "xip"; target = "ns-aws.nono.io."; })
  ];

  internalServices = [
    (CNAME { name = "asf"; target = "soyoustart"; cloudflare = true; })
    (CNAME { name = "autoconfig"; target = "50kvm"; cloudflare = true; })
    (CNAME { name = "bitwarden"; target = "virmach-ny6g"; ttl = "1h"; })
    (CNAME { name = "buypass-ssl"; target = "50kvm"; ttl = "1h"; })
    (CNAME { name = "ca"; target = "virmach-ny6g"; ttl = "1h"; })
    (CNAME { name = "ci"; target = "soyoustart"; cloudflare = true; })
    (CNAME { name = "ci-github"; target = "soyoustart"; cloudflare = true; })
    (CNAME { name = "cloud"; target = "virmach-ny1g"; cloudflare = true; })
    (CNAME { name = "dashboard"; target = "virmach-ny6g"; ttl = "1h"; })
    (CNAME { name = "git"; target = "virmach-ny1g"; ttl = "1h"; })
    (CNAME { name = "gopher"; target = "hostdare"; ttl = "1h"; })
    (CNAME { name = "himawari"; target = "virmach-ny1g"; cloudflare = true; })
    (CNAME { name = "irc"; target = "virmach-ny6g"; ttl = "1h"; })
    (CNAME { name = "lab"; target = "virmach-ny1g"; ttl = "1h"; })
    (CNAME { name = "lab-alt"; target = "virmach-ny1g"; cloudflare = true; })
    (CNAME { name = "ldap"; target = "virmach-ny6g"; ttl = "1h"; })
    (CNAME { name = "lg"; target = "virmach-ny6g"; cloudflare = true; })
    (CNAME { name = "lg-alt"; target = "virmach-ny6g"; cloudflare = true; })
    (CNAME { name = "login"; target = "virmach-ny6g"; cloudflare = true; })
    (CNAME { name = "pb"; target = "virmach-ny6g"; cloudflare = true; })
    (CNAME { name = "pma"; target = "virmach-ny1g"; cloudflare = true; })
    (CNAME { name = "resilio"; target = "soyoustart"; cloudflare = true; })
    (CNAME { name = "vault"; target = "soyoustart"; cloudflare = true; })
    (CNAME { name = "whois"; target = "hostdare"; ttl = "1h"; })
    (CNAME { name = "www"; target = "@"; cloudflare = true; })
  ]
  ++ (serveWithOwnNS "asn")
  ++ (serveWithOwnNS "dn42")
  ++ (serveWithOwnNS "neo")
  ++ (serveWithOwnNS "zt")
  ++ [
    (DS { name = "asn"; keytag = 48539; algorithm = 13; digesttype = 2; digest = "7D653B29D41EDF8A607B3119AF7FF3F0C1AE6EBFD19AA6FA1CCF1590E74DE1B6"; ttl = "1d"; })
    (DS { name = "asn"; keytag = 48539; algorithm = 13; digesttype = 4; digest = "0F8035F6A9BF09C806FE665445524632ADFA53E23BFB225E2128963ADAAD5B18294831A345A0AE06FA42E9217DEA0E2A"; ttl = "1d"; })
    (DS { name = "dn42"; keytag = 58078; algorithm = 13; digesttype = 2; digest = "81A243A02CCC549E29AF8959F725E0D9B32DF57CCC1F3CE1EA5520DE3839AE27"; ttl = "1d"; })
    (DS { name = "dn42"; keytag = 58078; algorithm = 13; digesttype = 4; digest = "70CE8555B82DFE3350E5B889B33B715B93EC2289F88F43B1F401037FD2F77C07B5ED45249EBBB99EDACCD50E521BFDC4"; ttl = "1d"; })
    (DS { name = "neo"; keytag = 53977; algorithm = 13; digesttype = 2; digest = "95DA7BDF34B30EDAB194A4304888C130CE4B4F19A6F953B9C045341939CEB902"; ttl = "1d"; })
    (DS { name = "neo"; keytag = 53977; algorithm = 13; digesttype = 4; digest = "FF20A56AA9E3C4F5AB3FB7B8520AD352A695198186224F4B893DF009CE4C7F96C92FF815B5D1F47209D31C1828006A3C"; ttl = "1d"; })
    (DS { name = "zt"; keytag = 44508; algorithm = 13; digesttype = 2; digest = "A63BA97D0639ADB92D28FC6780C7BDAEFD2FF51F927AA1B6D17C9F147DEA2439"; ttl = "1d"; })
    (DS { name = "zt"; keytag = 44508; algorithm = 13; digesttype = 4; digest = "AD99A5D4C58656CEACA84510BAE3DF9E3FB7A3C98F201D94FA45D1FCA0BFCC323BF3CBB56C3687CA2FBCF7C68702F117"; ttl = "1d"; })
  ]
  ;
}
