{ config, pkgs, lib, ... }:

let
  LT = import ../../../helpers { inherit config pkgs lib; };
in
rec {
  DN42_AS = "4242422547";
  DN42_TEST_AS = "4242422557";
  DN42_REGION = builtins.toString LT.this.dn42.region;
  NEO_AS = "4201270010";

  community = {
    LT_POLICY_DROP = "(${DN42_AS}, 1, 1)";
    LT_POLICY_NO_EXPORT = "(${DN42_AS}, 1, 2)";
    LT_POLICY_NO_KERNEL = "(${DN42_AS}, 1, 3)";
    LT_ROA_FAIL = "(${DN42_AS}, 2547, 0)";
    LT_ROA_UNKNOWN = "(${DN42_AS}, 2547, 1)";
  };

  sanitizeHostname = builtins.replaceStrings [ "-" ] [ "_" ];
}
