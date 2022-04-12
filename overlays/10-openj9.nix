{ inputs, nixpkgs, ... }:

final: prev: rec {
  jdk8 = prev.adoptopenjdk-openj9-bin-8;
  jdk8_headless = jdk8;
  jre8 = prev.adoptopenjdk-jre-openj9-bin-8;
  jre8_headless = jre8;

  jdk11 = prev.adoptopenjdk-openj9-bin-11;
  jdk11_headless = jdk11;
  jre11 = prev.adoptopenjdk-jre-openj9-bin-11;
  jre11_headless = jre11;

  jdk = prev.adoptopenjdk-openj9-bin-16;
  jre = prev.adoptopenjdk-jre-openj9-bin-16;
  jre_headless = jre;
  jre_minimal = jre;

  hath = prev.hath.override { inherit jre_headless; };
  minecraft = prev.minecraft.override { inherit jre; };
}
