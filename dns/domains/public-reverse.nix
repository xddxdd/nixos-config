{
  pkgs,
  config,
  lib,
  LT,
  inputs,
  ...
} @ args: {
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
      prefix = "2001:470:cab6::/48";
      target = "v-ps-fal.lantian.pub.";
    })
    (config.common.reverse {
      prefix = "2001:470:1f13:3b1::/64";
      target = "v-ps-fal.lantian.pub.";
    })

    (config.common.reverse {
      prefix = "2605:6400:cac6::/48";
      target = "buyvm.lantian.pub.";
    })
  ];
}
