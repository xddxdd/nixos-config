{ inputs, nixpkgs, ... }:

final: prev: rec {
  jdk8 = prev.openj9-ibm-semeru."8".jdk;
  jdk8_headless = jdk8;
  jre8 = prev.openj9-ibm-semeru."8".jre;
  jre8_headless = jre8;

  jdk11 = prev.openj9-ibm-semeru."11".jdk;
  jdk11_headless = jdk11;
  jre11 = prev.openj9-ibm-semeru."11".jre;
  jre11_headless = jre11;

  jdk17 = prev.openj9-ibm-semeru."17".jdk;
  jdk17_headless = jdk17;
  jre17 = prev.openj9-ibm-semeru."17".jre;
  jre17_headless = jre17;

  jdk = prev.openj9-ibm-semeru."17".jdk;
  jre = prev.openj9-ibm-semeru."17".jdk;
  jre_headless = jre;
  jre_minimal = jre;

  hath = prev.hath.override { inherit jre_headless; };
  grasscutter = prev.grasscutter.override { inherit jre_headless; };
  minecraft = prev.minecraft.override { inherit jre; };
}
