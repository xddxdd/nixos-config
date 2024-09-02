{ pkgs, ... }:
let
  sx1302HalConfig = pkgs.writeText "sx1302_local_conf.json" (
    builtins.toJSON {
      "gateway_conf" = {
        "gps_i2c_path" = "/dev/i2c-1";
        "gateway_ID" = "AA555A0000000000";
        # change with default server address/ports
        "server_address" = "localhost";
        "serv_port_up" = 1680;
        "serv_port_down" = 1680;
        # adjust the following parameters for your network
        "keepalive_interval" = 10;
        "stat_interval" = 30;
        "push_timeout_ms" = 100;
        # forward only valid packets
        "forward_crc_valid" = true;
        "forward_crc_error" = false;
        "forward_crc_disabled" = false;
      };
    }
  );
in
{
  systemd.services.lora-sx1302-hal = {
    description = "LoRa SX1302 HAL";
    wantedBy = [ "multi-user.target" ];

    # reset_lgw.sh modified according to https://github.com/Lora-net/sx1302_hal/issues/67
    preStart = ''
      install -Dm755 ${./reset_lgw.sh} reset_lgw.sh
      install -Dm644 ${sx1302HalConfig} local_conf.json
    '';

    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = "3";
      ExecStart = "${pkgs.sx1302-hal}/bin/lora_pkt_fwd -c ${pkgs.sx1302-hal}/conf/global_conf.json.sx1250.US915";
      RuntimeDirectory = "sx1302-hal";
      WorkingDirectory = "/run/sx1302-hal";
    };
  };
}
