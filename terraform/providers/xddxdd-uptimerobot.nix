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
    rev = "b37b4e6fe8b8691b0ebcc59633903d0f9500508b";
    version = "1.0.2";
    hash = "sha256-7GfWdet+2NsYxknSIHVmReXoSB3BGBi9vfcbwwdX31M=";
    vendorHash = "sha256-JvdX00fZLzZSEZsLFv4eBkpp8fPmgNLr3Yxrtawnr0Q=";
    provider-source-address = "private.lantian.pub/xddxdd/uptimerobot";
  }
