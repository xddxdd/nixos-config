_: final: prev:
let
  sources = final.callPackage ../helpers/_sources/generated.nix { };

  evebox-webapp = final.buildNpmPackage {
    pname = "evebox-webapp";
    inherit (sources.evebox) version src;
    sourceRoot = "source/webapp";
    npmDepsHash = "sha256-IYtAHNgaUIPM00dV3mcpo7GnOxUaKH6YafEvLViGz00=";

    postPatch = ''
      echo 'export const GIT_REV = "${sources.evebox.version}";' > src/gitrev.ts
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
  # cargoHash/cargoLock 无法通过 overrideAttrs 覆盖（见 nixpkgs lldap 的 workaround 注释），
  # 因此直接从 nvfetcher 源码全新构建
  evebox = final.rustPlatform.buildRustPackage {
    pname = "evebox";
    inherit (sources.evebox) version src;

    # 0.19+ 的 build.rs 在没有 git 仓库时会 panic，需显式提供 BUILD_REV
    env.BUILD_REV = sources.evebox.version;

    # 0.20+ 默认启用 pcap 功能，链接时需要 libpcap
    buildInputs = [ final.libpcap ];

    # 测试需要系统 CA 证书且部分依赖网络，全部跳过
    doCheck = false;

    # 依赖全部来自 crates.io，直接由 Cargo.lock 解析，无需计算 cargoHash
    cargoLock.lockFile = "${sources.evebox.src}/Cargo.lock";

    # 把构建好的 webapp 拷入源码树，随 rust-embed 嵌入二进制
    preBuild = ''
      mkdir -p resources
      cp -r ${evebox-webapp}/. resources/webapp
    '';

    meta = {
      description = "Web Based Event Viewer (GUI) for Suricata EVE Events in Elastic Search";
      homepage = "https://evebox.org/";
      changelog = "https://github.com/jasonish/evebox/releases/tag/${sources.evebox.version}";
      license = final.lib.licenses.mit;
      mainProgram = "evebox";
      broken = final.stdenv.hostPlatform.isDarwin;
    };
  };
}
