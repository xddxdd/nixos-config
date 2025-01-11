{
  config,
  pkgs,
  inputs,
  utils,
  ...
}:
let
  gwmp-mux = pkgs.nur-xddxdd.gwmp-mux.overrideAttrs (old: {
    postPatch =
      (old.postPatch or "")
      + ''
        substituteInPlace src/gwmp_mux.rs \
          --replace-fail "[0, 0, 0, 0]" "[127, 0, 0, 1]"
      '';
  });

  sx1302Hal = pkgs.nur-xddxdd.sx1302-hal.overrideAttrs (old: {
    postPatch =
      (old.postPatch or "")
      + ''
        find . -type f -exec sed -i 's#system("./reset_lgw.sh#system("reset_lgw.sh#g' {} \;
      '';
  });

  sx1302ServerConfig = {
    "gateway_ID" = {
      _secret = config.age.secrets.lora-euid.path;
    };
    "server_address" = "127.0.0.1";
    "serv_port_up" = 1681;
    "serv_port_down" = 1681;
  };

  sx1302HalConfig = {
    "gateway_conf" = sx1302ServerConfig // {
      "servers" = [
        (
          sx1302ServerConfig
          // {
            "serv_enabled" = true;
          }
        )
      ];

      "gps_i2c_path" = "/dev/i2c-1";
      # adjust the following parameters for your network
      "keepalive_interval" = 10;
      "stat_interval" = 30;
      "push_timeout_ms" = 100;
      # forward only valid packets
      "forward_crc_valid" = true;
      "forward_crc_error" = false;
      "forward_crc_disabled" = false;
    };
  };

  # reset_lgw.sh modified according to https://github.com/Lora-net/sx1302_hal/issues/67
  resetLgw = pkgs.linkFarm "reset-lgw" {
    "bin/reset_lgw.sh" = ./reset_lgw.sh;
  };
in
{
  age.secrets.lora-euid.file = inputs.secrets + "/lora-euid.age";

  systemd.services.lora-gwmp-mux = {
    description = "LoRa GWMP Mux";
    wantedBy = [ "multi-user.target" ];

    script = ''
      set -euo pipefail
      TTN_IP=$(${pkgs.dnsutils}/bin/dig +short nam1.cloud.thethings.network | head -n1)

      sleep infinity | ${gwmp-mux}/bin/gwmp-mux \
        --host 1681 \
        --client $TTN_IP:1700
    '';

    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = "3";
    };
  };

  systemd.services.lora-sx1302-hal = {
    description = "LoRa SX1302 HAL";
    wantedBy = [ "multi-user.target" ];

    path = [ resetLgw ];

    preStart = ''
      ${utils.genJqSecretsReplacementSnippet sx1302HalConfig "local_conf.json"}
    '';

    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = "3";
      ExecStart = "${sx1302Hal}/bin/lora_pkt_fwd -c ${sx1302Hal}/conf/global_conf.json.sx1250.US915";
      RuntimeDirectory = "sx1302-hal";
      WorkingDirectory = "/run/sx1302-hal";
    };
  };
}
