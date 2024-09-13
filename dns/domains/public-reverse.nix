{ config, ... }:
{
  domains = [
    (config.common.reverse {
      prefix = "2001:470:8a6d::/48";
      target = "virmach-ny1g.lantian.pub.";
    })
    (config.common.reverse {
      prefix = "2001:470:1f07:54d::/64";
      target = "virmach-ny1g.lantian.pub.";
    })

    (config.common.reverse {
      prefix = "2001:470:8d00::/48";
      target = "virmach-ny6g.lantian.pub.";
    })
    (config.common.reverse {
      prefix = "2001:470:1f07:c6f::/64";
      target = "virmach-ny6g.lantian.pub.";
    })

    (config.common.reverse {
      prefix = "2001:470:488d::/48";
      target = "hostdare.lantian.pub.";
    })
    (config.common.reverse {
      prefix = "2001:470:67:ee::/64";
      target = "hostdare.lantian.pub.";
    })

    (config.common.reverse {
      prefix = "2001:470:e997::/48";
      target = "lt-home-vm.lantian.pub.";
    })
    (config.common.reverse {
      prefix = "2001:470:b:3af::/64";
      target = "lt-home-vm.lantian.pub.";
    })

    (config.common.reverse {
      prefix = "2605:6400:cac6::/48";
      target = "buyvm.lantian.pub.";
    })
  ];
}
