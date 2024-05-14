{
  lib,
  fetchFromGitHub,
  buildGoModule,
  ...
}:
{
  owner,
  repo,
  rev,
  spdx ? "UNSET",
  version ? lib.removePrefix "v" rev,
  hash ? throw "use hash instead of sha256", # added 2202/09
  vendorHash ? throw "use vendorHash instead of vendorSha256", # added 2202/09
  deleteVendor ? false,
  proxyVendor ? false,
  mkProviderFetcher ? fetchFromGitHub,
  mkProviderGoModule ? buildGoModule,
  # "https://registry.terraform.io/providers/vancluever/acme"
  homepage ? "",
  # "registry.terraform.io/vancluever/acme"
  provider-source-address ?
    lib.replaceStrings
      [
        "https://registry"
        ".io/providers"
      ]
      [
        "registry"
        ".io"
      ]
      homepage,
  ...
}@attrs:
assert lib.stringLength provider-source-address > 0;
mkProviderGoModule {
  pname = repo;
  inherit
    vendorHash
    version
    deleteVendor
    proxyVendor
    ;
  subPackages = [ "." ];
  doCheck = false;
  # https://github.com/hashicorp/terraform-provider-scaffolding/blob/a8ac8375a7082befe55b71c8cbb048493dd220c2/.goreleaser.yml
  # goreleaser (used for builds distributed via terraform registry) requires that CGO is disabled
  CGO_ENABLED = 0;
  ldflags = [
    "-s"
    "-w"
    "-X main.version=${version}"
    "-X main.commit=${rev}"
  ];
  src = mkProviderFetcher {
    name = "source-${rev}";
    inherit
      owner
      repo
      rev
      hash
      ;
  };

  meta = {
    inherit homepage;
    license = lib.getLicenseFromSpdxId spdx;
  };

  # Move the provider to libexec
  postInstall = ''
    dir=$out/libexec/terraform-providers/${provider-source-address}/${version}/''${GOOS}_''${GOARCH}
    mkdir -p "$dir"
    mv $out/bin/* "$dir/terraform-provider-$(basename ${provider-source-address})_${version}"
    rmdir $out/bin
  '';

  # Keep the attributes around for later consumption
  passthru = attrs // {
    inherit provider-source-address;
  };
}
