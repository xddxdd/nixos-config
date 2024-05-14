{ callPackage, ... }:
let
  builder = callPackage ./_builder.nix { };
in
builder {
  owner = "xddxdd";
  repo = "terraform-provider-uptimerobot";
  rev = "ae19c6a1a45504fe1d5ef956cbf256835327be26";
  version = "1.0.4";
  hash = "sha256-LXqq5CsL9lhtDQYXpeg5qplNRtehioZYb0Eu55NeR/U=";
  vendorHash = "sha256-JvdX00fZLzZSEZsLFv4eBkpp8fPmgNLr3Yxrtawnr0Q=";
  provider-source-address = "private.lantian.pub/xddxdd/uptimerobot";
}
