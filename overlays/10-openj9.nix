{ inputs, nixpkgs, ... }:

final: prev: rec {
  jdk8 = prev.openj9-ibm-semeru.jdk-bin-8;
  jdk8_headless = jdk8;
  jre8 = prev.openj9-ibm-semeru.jre-bin-8;
  jre8_headless = jre8;

  jdk11 = prev.openj9-ibm-semeru.jdk-bin-11;
  jdk11_headless = jdk11;
  jre11 = prev.openj9-ibm-semeru.jre-bin-11;
  jre11_headless = jre11;

  jdk17 = prev.openj9-ibm-semeru.jdk-bin-17;
  jdk17_headless = jdk17;
  jre17 = prev.openj9-ibm-semeru.jre-bin-17;
  jre17_headless = jre17;

  jdk = prev.openj9-ibm-semeru.jdk-bin-17;
  jre = prev.openj9-ibm-semeru.jre-bin-17;
  jre_headless = jre;
  jre_minimal = jre;

  hath = prev.hath.override { inherit jre_headless; };
  grasscutter = prev.grasscutter.override { inherit jre_headless; };
  minecraft = prev.minecraft.override { inherit jre; };
}
