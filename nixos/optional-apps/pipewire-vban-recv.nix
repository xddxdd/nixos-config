{ LT, ... }:
{
  # VBAN receiver binds 0.0.0.0 on its default port 6980; LAN/LTnet only
  # by policy (public firewall preset rejects it from WAN).
  lantian.firewall.zones = {
    LAN.udpPorts."${LT.portStr.Pipewire.VBanRecv}".type = "local";
  };

  services.pipewire.extraConfig.pipewire = {
    "50-vban-recv.conf" = {
      "context.modules" = [
        {
          name = "libpipewire-module-vban-recv";
          args = {
            "source.name" = "VBAN Receiver";
            # Pin the receiver port; the module default (6980) is kept and
            # declared as a local port in the LAN zone.
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
