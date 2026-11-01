{
  lib,
  buildGoModule,
  pkg-config,
  knot-dns,
  gnutls,
  source,
}:
buildGoModule (finalAttrs: {
  pname = "knot-exporter";
  version = "3.5.3";
  inherit (source) src;

  vendorHash = "sha256-D+D+hzTxXcWlUtkTo48ZHOKS1mn81nSX/qnNzz1FNus=";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [
    knot-dns
    gnutls
  ];
  env.CGO_ENABLED = 1;

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
    "-X main.gitCommit=${source.version}"
  ];

  meta = {
    description = "Prometheus exporter for Knot DNS written in Go";
    homepage = "https://github.com/CZ-NIC/knot-exporter";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "knot-exporter";
  };
})
