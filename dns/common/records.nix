{ pkgs, dns, ... }:

with dns;
{
  ForwardEmail = [
    (MX { name = "@"; priority = 10; target = "mx1.forwardemail.net."; })
    (MX { name = "@"; priority = 10; target = "mx2.forwardemail.net."; })
    (MX { name = "@"; priority = 20; target = "mx.mailtie.com."; })
    (TXT { name = "@"; contents = "v=DMARC1; p=none"; })
    (TXT { name = "@"; contents = "v=spf1 a mx include:spf.forwardemail.net -all"; })
    (TXT { name = "@"; contents = "forward-email=xuyh0120@gmail.com"; })
    (TXT { name = "@"; contents = "mailtie=xuyh0120@gmail.com"; })
    (TXT { name = "_dmarc"; contents = "v=DMARC1; p=none"; })
  ];
}
