{ pkgs, dns, ... }:

with dns;
[
  (A { name = "vpshared"; address = "23.95.217.2"; })
  (A { name = "www.vpshared"; address = "23.95.217.2"; })

  (CNAME { name = "ipfs"; target = "cloudflare-ipfs.com."; })
  (CNAME { name = "lab"; target = "lab.lantian.pub."; })
  (CNAME { name = "*"; target = "soyoustart.lantian.pub."; })
  (ALIAS { name = "@"; target = "hostdare.lantian.pub."; })

  (TXT { name = "smtp._domainkey"; contents = "k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDTxp7BMZ/qsCTbr2AbL/Lxrdnkq05XiytoVI4JVelrJs/52bVuXhNQl4BBj2r9m9DUfNLzW5/7EGFCJEkzU/8NlzxLUYxU+QNE/3yqEyB7dBAB5yA/lDXZN7rJTlkpvFqKkstbcqeqSHK5tvxVoOgOAPj5PZQOWALk9Z6LX6gEDQIDAQAB"; })
  (TXT { name = "@"; contents = "google-site-verification=dFXi0jyD7Qm4WrRUaC79-XQWAJ4UwcdNSbGNTI9IvLg"; })

  (MX { name = "@"; priority = 10; target = "mx1.forwardemail.net."; })
  (MX { name = "@"; priority = 10; target = "mx2.forwardemail.net."; })
  (TXT { name = "@"; contents = "forward-email=xuyh0120@gmail.com"; })

  (CNAME { name = "s1._domainkey"; target = "s1.domainkey.u6126456.wl207.sendgrid.net."; })
  (CNAME { name = "s2._domainkey"; target = "s2.domainkey.u6126456.wl207.sendgrid.net."; })
  (CNAME { name = "em3816"; target = "u6126456.wl207.sendgrid.net."; })
  (CNAME { name = "url9203"; target = "sendgrid.net."; })
  (CNAME { name = "6126456"; target = "sendgrid.net."; })
]
