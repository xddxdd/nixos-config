{
  stateVersion = "22.05";

  soundfontPath = pkgs: "${pkgs.soundfont-fluid}/share/soundfonts/FluidR3_GM2-2.sf2";

  dn42Zones = [ "dn42" "10.in-addr.arpa" "20.172.in-addr.arpa" "21.172.in-addr.arpa" "22.172.in-addr.arpa" "23.172.in-addr.arpa" "31.172.in-addr.arpa" "d.f.ip6.arpa" ];
  neonetworkZones = [ "neo" ];
  # .neo zone not included for conflict with NeoNetwork
  openNICZones = [ "bbs" "chan" "cyb" "dns.opennic.glue" "dyn" "epic" "fur" "geek" "gopher" "indy" "libre" "null" "o" "opennic.glue" "oss" "oz" "parody" "pirate" ];
  emercoinZones = [ "bazar" "coin" "emc" "lib" ];
  yggdrasilAlfisZones = ["anon" "btn" "conf" "index" "merch" "mirror" "mob" "screen" "srv" "ygg"];
}
