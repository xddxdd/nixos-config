{
  pkgs,
  lib,
  config,
  ...
}@args:
{
  options.lantian.pipewire.roc-sink-ip = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
  };

  config.services.pipewire.configPackages = builtins.map (
    ip:
    (pkgs.writeTextFile {
      name = "pipewire-roc-sink-${ip}";
      text = builtins.toJSON {
        "context.modules" = [
          {
            name = "libpipewire-module-roc-sink";
            args = {
              "remote.ip" = ip;
              "remote.source.port" = 10001;
              "remote.repair.port" = 10002;
              "remote.control.port" = 10003;
              "fec.code" = "rs8m";
              "sink.name" = "ROC Sink (${ip})";
              "sink.props" = {
                "node.name" = "roc-sink-${ip}";
                "node.description" = "ROC Sink (${ip})";
              };
            };
          }
        ];
      };
      destination = "/share/pipewire/pipewire.conf.d/roc-sink-${ip}.conf";
    })
  ) config.lantian.pipewire.roc-sink-ip;
}
