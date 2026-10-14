{
  fetchFromGitHub,
  go_1_27,
  buildGoModule,
  lib,
  olm,
}:

# Fork's go.mod pins Go 1.27 which the default toolchain (go 1.26) cannot
# satisfy; build with go 1.27 and relax the directive to 1.27 for 1.27.1.
(buildGoModule.override { go = go_1_27; } rec {
  pname = "picoclaw";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "afjcjsbx";
    repo = "picoclaw";
    tag = "v${version}";
    hash = "sha256-ecH2BXMOQK0DoRIht8bbrrcB13l7YFvanyGsmmPnr30=";
  };

  vendorHash = "sha256-oRHaV6YIVIG+zCIm1vwjtadlGVCsaH5O14/PBAp4R40=";

  # Upstream pins go.mod to a newer Go patch than nixpkgs ships; relax the go
  # directive to the major.minor of the build toolchain, otherwise the toolchain
  # check/GOTOOLCHAIN switch fails under GOTOOLCHAIN=local.
  postPatch = ''
    sed -i -E "s/^go .*/go ${lib.versions.majorMinor go_1_27.version}/" go.mod
  '';

  patches = [
    ../../patches/picoclaw-disable-command-restrictions.patch
    ../../patches/picoclaw-mcp-json.patch
  ];

  # Tests require runtime configuration and network access
  doCheck = false;

  buildInputs = [
    # mautrix-go crypto backend links libolm via cgo. libolm is marked
    # insecure in nixpkgs (deprecated upstream, timing side-channels in
    # its AES/SHA primitives). Accepted here because Matrix is an optional
    # chat backend and the pure-Go goolm alternative is still experimental.
    (olm.overrideAttrs (old: {
      meta = old.meta // {
        knownVulnerabilities = [ ];
      };
    }))
  ];

  subPackages = [ "cmd/picoclaw" ];

  # Fork keeps the upstream sipeed module path
  ldflags = [
    "-s"
    "-w"
    "-X github.com/sipeed/picoclaw/pkg/config.Version=${version}"
  ];

  meta = {
    description = "PicoClaw fork (afjcjsbx) — tiny self-hosted agent gateway";
    homepage = "https://github.com/afjcjsbx/picoclaw";
    license = lib.licenses.mit;
    mainProgram = "picoclaw";
    platforms = lib.platforms.unix;
  };
})
