# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub, dockerTools }:
{
  brlaser = {
    pname = "brlaser";
    version = "fed695c5e7de5432900624bda42578a4a88e081c";
    src = fetchFromGitHub {
      owner = "Owl-Maintain";
      repo = "brlaser";
      rev = "fed695c5e7de5432900624bda42578a4a88e081c";
      fetchSubmodules = false;
      sha256 = "sha256-HACJ884t3mUEQMfn8pn8nnSXGYPmd0J1STRtOigViJA=";
    };
    date = "2023-08-01";
  };
  cyberchef = {
    pname = "cyberchef";
    version = "v10.18.9";
    src = fetchurl {
      url = "https://github.com/gchq/CyberChef/releases/download/v10.18.9/CyberChef_v10.18.9.zip";
      sha256 = "sha256-4oUjOzbcfDb96vurJx2yPKmrgtc9g5izWlc2/ABymi4=";
    };
  };
  dashboard-icons = {
    pname = "dashboard-icons";
    version = "be82e22c418f5980ee2a13064d50f1483df39c8c";
    src = fetchFromGitHub {
      owner = "walkxcode";
      repo = "dashboard-icons";
      rev = "be82e22c418f5980ee2a13064d50f1483df39c8c";
      fetchSubmodules = false;
      sha256 = "sha256-z69DKzKhCVNnNHjRM3dX/DD+WJOL9wm1Im1nImhBc9Y=";
    };
    date = "2024-07-21";
  };
  grafana-falconlogscale-datasource = {
    pname = "grafana-falconlogscale-datasource";
    version = "1.7.0";
    src = fetchurl {
      url = "https://storage.googleapis.com/integration-artifacts/grafana-falconlogscale-datasource/release/1.7.0/linux/grafana-falconlogscale-datasource-1.7.0.linux_amd64.zip";
      sha256 = "sha256-mC6HlixTm6Zdm1uwmX1ecdZ+Drb1sYe0IvL2UW9qGxg=";
    };
  };
  grafana-yesoreyeram-infinity-datasource = {
    pname = "grafana-yesoreyeram-infinity-datasource";
    version = "2.9.4";
    src = fetchurl {
      url = "https://storage.googleapis.com/integration-artifacts/yesoreyeram-infinity-datasource/release/2.9.4/linux/yesoreyeram-infinity-datasource-2.9.4.linux_amd64.zip";
      sha256 = "sha256-aDJjQB+7fS2M1/shtZz6eFMuIORyfpnZg/Y9NwUBCjM=";
    };
  };
  himawaripy = {
    pname = "himawaripy";
    version = "v2.2.0";
    src = fetchFromGitHub {
      owner = "boramalper";
      repo = "himawaripy";
      rev = "v2.2.0";
      fetchSubmodules = false;
      sha256 = "sha256-GcHFB851ClQjFjqTMZbRuGdg4kWjAnou9w9l+UDYM5c=";
    };
  };
  jproxy = {
    pname = "jproxy";
    version = "v3.4.1";
    src = fetchurl {
      url = "https://github.com/LuckyPuppy514/jproxy/releases/download/v3.4.1/windows-v3.4.1.zip";
      sha256 = "sha256-DPYHHIc6bH8X3tUcEd4xE0W/Q5BBBofdEtM9x3T+0vk=";
    };
  };
  keycloak-lantian = {
    pname = "keycloak-lantian";
    version = "f499fb03624b6b396e6eef1263dd1650a95e63d2";
    src = fetchgit {
      url = "https://git.lantian.pub/lantian/keycloak-lantian.git";
      rev = "f499fb03624b6b396e6eef1263dd1650a95e63d2";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sparseCheckout = [ ];
      sha256 = "sha256-xiq4Ap75ma9GzwyRfAlgzoSBZNPWZoCFildo58U60/M=";
    };
    date = "2023-05-27";
  };
  material-kwin-decoration = {
    pname = "material-kwin-decoration";
    version = "0e989e5b815b64ee5bca989f983da68fa5556644";
    src = fetchFromGitHub {
      owner = "Zren";
      repo = "material-decoration";
      rev = "0e989e5b815b64ee5bca989f983da68fa5556644";
      fetchSubmodules = false;
      sha256 = "sha256-Ncn5jxkuN4ZBWihfycdQwpJ0j4sRpBGMCl6RNiH4mXg=";
    };
    date = "2023-01-15";
  };
  mihoyo-bbs-tools = {
    pname = "mihoyo-bbs-tools";
    version = "c780c30611ac402a10f4d244a1fbefc78867a3a6";
    src = fetchFromGitHub {
      owner = "Womsxd";
      repo = "MihoyoBBSTools";
      rev = "c780c30611ac402a10f4d244a1fbefc78867a3a6";
      fetchSubmodules = false;
      sha256 = "sha256-+shVvRVNhmaeI9jYOVtfTLJ88ntnPwPGWoGl0q9nXpk=";
    };
    date = "2024-07-19";
  };
  mpv-sockets = {
    pname = "mpv-sockets";
    version = "3b3f430074a67c63572a582847ed1fa69330c668";
    src = fetchFromGitHub {
      owner = "wis";
      repo = "mpvSockets";
      rev = "3b3f430074a67c63572a582847ed1fa69330c668";
      fetchSubmodules = false;
      sha256 = "sha256-KFv3imLuiV+APx4A8TSi2LXL5gdHNKc497fRwBubvMk=";
    };
    date = "2024-02-13";
  };
  nvidia-patch = {
    pname = "nvidia-patch";
    version = "c7221dd770279275a06f34e68b39b8d237ea9b7b";
    src = fetchFromGitHub {
      owner = "keylase";
      repo = "nvidia-patch";
      rev = "c7221dd770279275a06f34e68b39b8d237ea9b7b";
      fetchSubmodules = false;
      sha256 = "sha256-fyN8hWVP6ITeOrfv3cpMyIYNyyqw7fFoHqj12FBq6vc=";
    };
    date = "2024-07-18";
  };
  openvpn = {
    pname = "openvpn";
    version = "418463ad27c13f56adb5b02cfd62018b7d634ee8";
    src = fetchFromGitHub {
      owner = "OpenVPN";
      repo = "openvpn";
      rev = "418463ad27c13f56adb5b02cfd62018b7d634ee8";
      fetchSubmodules = false;
      sha256 = "sha256-USlmSYcobno8+zFPoFwh+DcaPUz6beGrqPbzdUO8cGg=";
    };
    date = "2024-07-26";
  };
  openwrt-mt76 = {
    pname = "openwrt-mt76";
    version = "e25fb9a010f9c8a2975b71f68d5dc6c5dc011109";
    src = fetchFromGitHub {
      owner = "openwrt";
      repo = "mt76";
      rev = "e25fb9a010f9c8a2975b71f68d5dc6c5dc011109";
      fetchSubmodules = false;
      sha256 = "sha256-tn2ko0EEJHm2edBtGA0+hRVap2bbOq2f7iPe64nv4b4=";
    };
    date = "2024-07-16";
  };
  plasma-panel-transparency-toggle = {
    pname = "plasma-panel-transparency-toggle";
    version = "739c70ffde6bb7670d57d3507804408ae13edf25";
    src = fetchFromGitHub {
      owner = "sanjay-kr-commit";
      repo = "panelTransparencyToggleForPlasma6";
      rev = "739c70ffde6bb7670d57d3507804408ae13edf25";
      fetchSubmodules = false;
      sha256 = "sha256-1VKLkGw9jxJvYDoUgkRjnCT6+ol2dJAmppM61lvVOi8=";
    };
    date = "2024-04-17";
  };
  soggy-resources = {
    pname = "soggy-resources";
    version = "162538ae54d9d5d3864cfbee4ed5bab6cc38580d";
    src = fetchgit {
      url = "https://codeberg.org/LDA_suku/soggy_resources.git";
      rev = "162538ae54d9d5d3864cfbee4ed5bab6cc38580d";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sparseCheckout = [ ];
      sha256 = "sha256-d/vQBijlw6Pe/ze0fqayWTkbzJrarFlCCM1DxpNSxvQ=";
    };
    date = "2022-11-27";
  };
  ulauncher-albert-calculate-anything = {
    pname = "ulauncher-albert-calculate-anything";
    version = "037965a44e6f6f496e7ad71ec1651b9edfcde32d";
    src = fetchFromGitHub {
      owner = "tchar";
      repo = "ulauncher-albert-calculate-anything";
      rev = "037965a44e6f6f496e7ad71ec1651b9edfcde32d";
      fetchSubmodules = false;
      sha256 = "sha256-RUxkStLxM8wg4a5yicoQCTjLxSEsb3HQwDSwrQicc2U=";
    };
    date = "2024-05-29";
  };
  ulauncher-colorconverter = {
    pname = "ulauncher-colorconverter";
    version = "2d5e2bc17e89f1f1dc561f73e68ea574e0be844a";
    src = fetchFromGitHub {
      owner = "sergius02";
      repo = "ulauncher-colorconverter";
      rev = "2d5e2bc17e89f1f1dc561f73e68ea574e0be844a";
      fetchSubmodules = false;
      sha256 = "sha256-UfRU7BpQUj26THzE8kYLIRUfe7voGvAcGDBTsl+yCwU=";
    };
    date = "2020-12-06";
  };
  ulauncher-emoji = {
    pname = "ulauncher-emoji";
    version = "827cfe5e1d2f89f742f811f981759787b0654fa9";
    src = fetchFromGitHub {
      owner = "Ulauncher";
      repo = "ulauncher-emoji";
      rev = "827cfe5e1d2f89f742f811f981759787b0654fa9";
      fetchSubmodules = false;
      sha256 = "sha256-iXu0V7Vyij0fg+3psRx7r1nI9MGH6RmxdDW8/V/5slU=";
    };
    date = "2023-11-04";
  };
  ulauncher-meme-my-text = {
    pname = "ulauncher-meme-my-text";
    version = "5d62830a7a92983a731e15645831f53d48dad913";
    src = fetchFromGitHub {
      owner = "RNairn01";
      repo = "ulauncher-meme-my-text";
      rev = "5d62830a7a92983a731e15645831f53d48dad913";
      fetchSubmodules = false;
      sha256 = "sha256-vIWIl2qOWYVrCLhGoDXH4xTfhc+GhE9cVFuV1qjYaH0=";
    };
    date = "2021-05-07";
  };
  ulauncher-tldr = {
    pname = "ulauncher-tldr";
    version = "2e5904451bf89dfa155280dfb6fa3d45ed4cab4c";
    src = fetchFromGitHub {
      owner = "dhelmr";
      repo = "ulauncher-tldr";
      rev = "2e5904451bf89dfa155280dfb6fa3d45ed4cab4c";
      fetchSubmodules = false;
      sha256 = "sha256-B/17gbGFUar2+PVfVQWZc7Eq8zADK4CeGW3XHQMqiAg=";
    };
    date = "2023-07-29";
  };
  ulauncher-virtualbox = {
    pname = "ulauncher-virtualbox";
    version = "d8f495df3c7f41ee8493b207d17f06fc0372c84e";
    src = fetchFromGitHub {
      owner = "luispabon";
      repo = "ulauncher-virtualbox";
      rev = "d8f495df3c7f41ee8493b207d17f06fc0372c84e";
      fetchSubmodules = false;
      sha256 = "sha256-IT1qsXpwYkl5vKGEBI9WySpWm6zOfe9ewj5oNgC8/Ro=";
    };
    date = "2020-09-23";
  };
  ulauncher-vscode-recent = {
    pname = "ulauncher-vscode-recent";
    version = "60a5106821478f965e4e24dbe1833f6af0d437f1";
    src = fetchFromGitHub {
      owner = "plibither8";
      repo = "ulauncher-vscode-recent";
      rev = "60a5106821478f965e4e24dbe1833f6af0d437f1";
      fetchSubmodules = false;
      sha256 = "sha256-sJJzHXp8S/Powqz0FgSCqfWL81q/mXqBi1KucRFB2LE=";
    };
    date = "2023-12-01";
  };
  web-compressor = {
    pname = "web-compressor";
    version = "7c8e79dea7af1afad562b43268129ebbc72b0bb3";
    src = fetchFromGitHub {
      owner = "xddxdd";
      repo = "web-compressor";
      rev = "7c8e79dea7af1afad562b43268129ebbc72b0bb3";
      fetchSubmodules = false;
      sha256 = "sha256-KGZqQsV7oo3ggHP4ZBdK3/f3R6Eq7g5xr1o5GzVGXOM=";
    };
    date = "2023-11-18";
  };
  yourls = {
    pname = "yourls";
    version = "1.9.2";
    src = fetchFromGitHub {
      owner = "YOURLS";
      repo = "YOURLS";
      rev = "1.9.2";
      fetchSubmodules = false;
      sha256 = "sha256-eV8TMWa4woIjRJhuptS7MDVdgItOo5towjKYNlruIKo=";
    };
  };
  yourls-404-if-not-found = {
    pname = "yourls-404-if-not-found";
    version = "a611040c6f33cd6d00b07ddb824b9842ed2de2de";
    src = fetchFromGitHub {
      owner = "YOURLS";
      repo = "404-if-not-found";
      rev = "a611040c6f33cd6d00b07ddb824b9842ed2de2de";
      fetchSubmodules = false;
      sha256 = "sha256-3pgk7TkwuuTYz7eU9lxptkpqu0COOrWKZyt7Lp8VqLQ=";
    };
    date = "2023-12-16";
  };
  yourls-always-302 = {
    pname = "yourls-always-302";
    version = "c704f3d285fae60e0c49445c499a5bf4b235d411";
    src = fetchFromGitHub {
      owner = "tinjaw";
      repo = "Always-302";
      rev = "c704f3d285fae60e0c49445c499a5bf4b235d411";
      fetchSubmodules = false;
      sha256 = "sha256-llZagwjVWSXCupIzDQ90Rid6icKQ3PL5xoqIC0NzImg=";
    };
    date = "2020-08-22";
  };
  yourls-dont-track-admins = {
    pname = "yourls-dont-track-admins";
    version = "be87e385a52fb452d6b8c70e9fc28ca060a63f62";
    src = fetchFromGitHub {
      owner = "dgw";
      repo = "yourls-dont-track-admins";
      rev = "be87e385a52fb452d6b8c70e9fc28ca060a63f62";
      fetchSubmodules = false;
      sha256 = "sha256-GWCUpxPfD/bqwGS1Rhu12HVDK7hgQVCv2mlcI5OOvUg=";
    };
    date = "2022-05-30";
  };
  yourls-login-timeout = {
    pname = "yourls-login-timeout";
    version = "1a8eee5a5104c15660952abc49b79486d81917c6";
    src = fetchFromGitHub {
      owner = "reanimus";
      repo = "yourls-login-timeout";
      rev = "1a8eee5a5104c15660952abc49b79486d81917c6";
      fetchSubmodules = false;
      sha256 = "sha256-YGz09e2Fd9R1LcXVIGSjvlF7Hzn6KLB2ZiTL/jPlkSA=";
    };
    date = "2019-04-01";
  };
  yourls-sleeky = {
    pname = "yourls-sleeky";
    version = "f7978d9d426e4373a02785c5c008920f4bec7a96";
    src = fetchFromGitHub {
      owner = "Flynntes";
      repo = "Sleeky";
      rev = "f7978d9d426e4373a02785c5c008920f4bec7a96";
      fetchSubmodules = false;
      sha256 = "sha256-Y8w9awNm1s3FpNRrwhCvyvDj4hg51GAKzcWKOoOnipA=";
    };
    date = "2021-06-27";
  };
  zsh-autopair = {
    pname = "zsh-autopair";
    version = "449a7c3d095bc8f3d78cf37b9549f8bb4c383f3d";
    src = fetchFromGitHub {
      owner = "hlissner";
      repo = "zsh-autopair";
      rev = "449a7c3d095bc8f3d78cf37b9549f8bb4c383f3d";
      fetchSubmodules = false;
      sha256 = "sha256-3zvOgIi+q7+sTXrT+r/4v98qjeiEL4Wh64rxBYnwJvQ=";
    };
    date = "2024-07-14";
  };
}
