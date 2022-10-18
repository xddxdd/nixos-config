{ pkgs, lib, dns, ... }@args:

let
  inherit (pkgs.callPackage ./host-recs.nix args) fakeALIAS;
in
with dns;
rec {
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

  GeoDNSTarget = "geo.56631131.xyz."; # Hosted on NS1.com for GeoDNS
  GeoDNSAlias = "lantian.pub."; # Cloudflare handled alias to reduce query count on NS1

  Libravatar = [
    (fakeALIAS { name = "avatar"; target = "hostdare"; ttl = "1h"; })

    # Use fixed domain, vhost not set up for all domains for now
    (SRV { name = "_avatars._tcp"; priority = 0; weight = 0; port = 80; target = "avatar.lantian.pub."; })
    (SRV { name = "_avatars-sec._tcp"; priority = 0; weight = 0; port = 443; target = "avatar.lantian.pub."; })
  ];

  SIP = [
    (SRV { name = "_sip._udp"; priority = 0; weight = 0; port = 5060; target = "oneprovider"; })
    (SRV { name = "_sip._tcp"; priority = 0; weight = 0; port = 5060; target = "oneprovider"; })
    (SRV { name = "_sips._tcp"; priority = 0; weight = 0; port = 5061; target = "oneprovider"; })
  ];
}
