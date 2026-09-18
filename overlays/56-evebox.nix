_: final: prev:
let
  evebox-webapp = final.buildNpmPackage {
    pname = "evebox-webapp";
    inherit (prev.evebox) src version;
    sourceRoot = "source/webapp";
    npmDepsHash = "sha256-RCO/aoCOSCuYQulhm5HBzVJTaf6AF+y/g0Ee8sQgon0=";

    postPatch = ''
      echo 'export const GIT_REV = "${prev.evebox.version}";' > src/gitrev.ts
    '';

    dontNpmInstall = true;
    installPhase = ''
      runHook preInstall
      cp -r dist $out
      runHook postInstall
    '';
  };
in
{
  # 第二步：把构建好的 webapp 拷入 evebox 源码树，随 rust-embed 嵌入二进制
  evebox = prev.evebox.overrideAttrs (old: {
    preBuild = ''
      mkdir -p resources
      cp -r ${evebox-webapp}/. resources/webapp
    '';
  });
}
