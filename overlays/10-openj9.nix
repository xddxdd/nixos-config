{ inputs, lib, ... }:

final: prev: rec {
  jdk8 = final.openj9-ibm-semeru.jdk-bin-8;
  jdk8_headless = jdk8;
  jre8 = final.openj9-ibm-semeru.jre-bin-8;
  jre8_headless = jre8;

  jdk11 = final.openj9-ibm-semeru.jdk-bin-11;
  jdk11_headless = jdk11;
  jre11 = final.openj9-ibm-semeru.jre-bin-11;
  jre11_headless = jre11;

  jdk17 = final.openj9-ibm-semeru.jdk-bin-17;
  jdk17_headless = jdk17;
  jre17 = final.openj9-ibm-semeru.jre-bin-17;
  jre17_headless = jre17;

  jdk = final.openj9-ibm-semeru.jdk-bin-18;
  jre = final.openj9-ibm-semeru.jre-bin-18;
  jre_headless = jre;
  jre_minimal = jre;

  hath = prev.hath.override { inherit jre_headless; };
  grasscutter = prev.grasscutter.override { inherit jre_headless; };
  polymc = prev.polymc.override {
    jdk = final.openjdk;
    jdk8 = null;
    jdks = [ jdk jdk17 jdk11 jdk8 ]
      ++ (with final; [ openjdk17 openjdk11 openjdk8 ]);
  };
}
