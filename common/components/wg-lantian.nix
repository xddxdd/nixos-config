{ pkgs, config, ... }:

{
  networking.wireguard.interfaces.wg-lantian = {
    ips = [ "192.0.2.1/24" "fc00::1/64" ];
    listenPort = 22547;
    privateKeyFile = config.age.secrets.wg-priv.path;
    peers = [
      ({
        publicKey = "6akFoVWQ0AHZXuehuLP8x25Wfqy1lDrmu8DAX97mMjg=";
        allowedIPs = [ "192.0.2.2/32" "fc00::2/128" ];
      })
    ];
  };
}
