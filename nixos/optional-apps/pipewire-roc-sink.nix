{
  lib,
  config,
  ...
}@args:
{
  options.lantian.pipewire.roc-sink-ip = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
  };

  config.services.pipewire.extraConfig.pipewire = builtins.listToAttrs (
    builtins.map (
      ip:
      lib.nameValuePair "50-roc-sink-${ip}" {
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
                "node.passive" = true;
              };
            };
          }
        ];
      }
    ) config.lantian.pipewire.roc-sink-ip
  );
}
