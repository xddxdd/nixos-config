{ LT, ... }:
{
  # VBAN receiver binds 0.0.0.0 on its default port 6980; LAN/LTnet only
  # by policy (public firewall preset rejects it from WAN).
  lantian.firewall.presets.public-firewall.allowedInternalPorts = [ LT.port.Pipewire.VBanRecv ];

  services.pipewire.extraConfig.pipewire = {
    "50-vban-recv.conf" = {
      "context.modules" = [
        {
          name = "libpipewire-module-vban-recv";
          args = {
            "source.name" = "VBAN Receiver";
            # Pin the receiver port; the module default (6980) is kept and
            # declared as an internal port in the public-firewall preset.
            "port" = LT.port.Pipewire.VBanRecv;
            "source.props" = {
              "node.name" = "vban-recv";
              "node.description" = "VBAN Receiver";
              "media.class" = "Stream/Output/Audio";
              "sess.latency.msec" = 100;
              "audio.channels" = 2;
              "audio.format" = "S24LE";
              "audio.rate" = 44100;
            };
          };
        }
      ];
    };
  };
}
