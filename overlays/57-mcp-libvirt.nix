_: final: prev:
let
  sources = final.callPackage ../helpers/_sources/generated.nix { };
in
{
  mcp-libvirt = final.rustPlatform.buildRustPackage {
    pname = "mcp-libvirt";
    inherit (sources.mcp-libvirt) version src;

    nativeBuildInputs = [ final.pkg-config ];
    buildInputs = [ final.libvirt ];

    # 测试依赖 libvirt test driver（test:///default）并对 127.0.0.1:1 发起 TCP 连接
    doCheck = false;

    cargoHash = "sha256-FPhpBmZW50gs6/4PGiVE7NzMPI/0MMzwe6aJZUbAAmw=";

    meta = {
      description = "MCP server that drives libvirt domains over SPICE";
      homepage = "https://github.com/xddxdd/mcp-libvirt-vm-use";
      mainProgram = "mcp-libvirt";
      platforms = final.lib.platforms.linux;
    };
  };
}
