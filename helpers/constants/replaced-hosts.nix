_: {
  # Old host names that have been replaced by a new host.
  # Used by DNS record generation (dns/common/host-recs.nix), acme certificate
  # issuance (nixos/optional-apps/acme/base-domains.nix) and the nginx redirect
  # vhosts (nixos/common-apps/nginx/vhost-replaced-hosts.nix).
  # keep-sorted start
  "50kvm" = "alice";
  "v-ps-hkg" = "alice";
  "v-ps-sjc" = "bwg-lax";
  gigsgigscloud = "alice";
  hetzner-de = "colocrossing";
  hostdare = "bwg-lax";
  linkin = "alice";
  oneprovider = "colocrossing";
  soyoustart = "colocrossing";
  virmach-ny1g = "colocrossing";
  virmach-ny3ip = "colocrossing";
  virmach-ny6g = "colocrossing";
  virtono = "buyvm";
  # keep-sorted end
}
