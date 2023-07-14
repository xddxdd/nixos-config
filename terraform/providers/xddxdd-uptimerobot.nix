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
    rev = "eb7c3c6e0448367a64229fdb6733eeb07e7c62c7";
    version = "1.0.0";
    hash = "sha256-Y+9zOzPsTsH1J3Acn62ZePFtVDovbHCgENeqDfQq1fM=";
    vendorHash = "sha256-JvdX00fZLzZSEZsLFv4eBkpp8fPmgNLr3Yxrtawnr0Q=";
    provider-source-address = "private.lantian.pub/xddxdd/uptimerobot";
  }
