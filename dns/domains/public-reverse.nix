{ pkgs, lib, dns, common, ... }:

[
  (common.reverse { prefix = "2001:470:fa1d::/48"; target = "50kvm.lantian.pub."; })
  (common.reverse { prefix = "2001:470:19:10bd::/64"; target = "50kvm.lantian.pub."; })
  (common.reverse { prefix = "2001:470:8a6d::/48"; target = "virmach-ny1g.lantian.pub."; })
  (common.reverse { prefix = "2001:470:1f07:54d::/64"; target = "virmach-ny1g.lantian.pub."; })
  (common.reverse { prefix = "2001:470:8d00::/48"; target = "virmach-ny6g.lantian.pub."; })
  (common.reverse { prefix = "2001:470:1f07:c6f::/64"; target = "virmach-ny6g.lantian.pub."; })
  (common.reverse { prefix = "2605:6400:cac6::/48"; target = "buyvm.lantian.pub."; })
]
