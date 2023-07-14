{
  lib,
  callPackage,
  ...
}: let
  builder = callPackage ./_builder.nix {};
in
  builder {
    owner = "xddxdd";
    repo = "terraform-provider-uptimerobot";
    rev = "4d919b64934f3e61ce5ecbc0c9b7e1752ff23b72";
    version = "1.0.1";
    hash = "sha256-6M8OyG2U83qoagFeuuHurx+I38mwO/DIj1J5gtPHe6U=";
    vendorHash = "sha256-JvdX00fZLzZSEZsLFv4eBkpp8fPmgNLr3Yxrtawnr0Q=";
    provider-source-address = "private.lantian.pub/xddxdd/uptimerobot";
  }
