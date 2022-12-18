{ pkgs, lib, LT, config, utils, inputs, ... }@args:

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

  latencyToDN42Community = { latencyMs, badRouting, ... }:
    if badRouting then 9 else
    if latencyMs <= 3 then 1 else
    if latencyMs <= 7 then 2 else
    if latencyMs <= 20 then 3 else
    if latencyMs <= 55 then 4 else
    if latencyMs <= 148 then 5 else
    if latencyMs <= 403 then 6 else
    if latencyMs <= 1097 then 7 else
    if latencyMs <= 2981 then 8 else
    9;

  typeToDN42Community = type:
    if type == "openvpn" then 33 else
    if type == "wireguard" then 34 else
    if type == "gre" then 31 else
    31;
}
