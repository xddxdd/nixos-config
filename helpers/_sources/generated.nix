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
    version = "v10.18.6";
    src = fetchurl {
      url = "https://github.com/gchq/CyberChef/releases/download/v10.18.6/CyberChef_v10.18.6.zip";
      sha256 = "sha256-XGUwCRKtPFd6cDQXODaLHDKBiENHYQSshWDLNZ9vEy4=";
    };
  };
  dashboard-icons = {
    pname = "dashboard-icons";
    version = "dd34fba44b97d3d5753dda032487890cb6fa5879";
    src = fetchFromGitHub {
      owner = "walkxcode";
      repo = "dashboard-icons";
      rev = "dd34fba44b97d3d5753dda032487890cb6fa5879";
      fetchSubmodules = false;
      sha256 = "sha256-gi8L548tvGByLsyUZQeSfIxM6I959ehxhYA3mST+Qa0=";
    };
    date = "2024-06-02";
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
  homer = {
    pname = "homer";
    version = "v24.05.1";
    src = fetchurl {
      url = "https://github.com/bastienwirtz/homer/releases/download/v24.05.1/homer.zip";
      sha256 = "sha256-Ji/7BSKCnnhj4NIdGngTHcGRRbx9UWrx48bBsKkEj34=";
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
    version = "ae35eddfe12cd690d97cae557e0f5644dabec12e";
    src = fetchFromGitHub {
      owner = "Womsxd";
      repo = "MihoyoBBSTools";
      rev = "ae35eddfe12cd690d97cae557e0f5644dabec12e";
      fetchSubmodules = false;
      sha256 = "sha256-Bea1ODBV6dRnvV6LnK7TKI6ZB5E3dHpPgU9ezY0s/Hw=";
    };
    date = "2024-05-31";
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
    version = "fe90cd0af2f9c73be1c76c8333acc9d3301f00ce";
    src = fetchFromGitHub {
      owner = "keylase";
      repo = "nvidia-patch";
      rev = "fe90cd0af2f9c73be1c76c8333acc9d3301f00ce";
      fetchSubmodules = false;
      sha256 = "sha256-khwSsU/naWc2V589DJ0BIcLldFzo0Pn+JD9nESu2TJM=";
    };
    date = "2024-05-28";
  };
  openvpn = {
    pname = "openvpn";
    version = "13ee7f902f18e27b981f8e440facd2e6515c6c83";
    src = fetchFromGitHub {
      owner = "OpenVPN";
      repo = "openvpn";
      rev = "13ee7f902f18e27b981f8e440facd2e6515c6c83";
      fetchSubmodules = false;
      sha256 = "sha256-Jjs2qLG1nSjbETqsHNg79gW0uS3EY2Elg/US3rTE53c=";
    };
    date = "2024-06-06";
  };
  openwrt-mt76 = {
    pname = "openwrt-mt76";
    version = "513c131c6309712a51502870b041f45b4bd6a6d4";
    src = fetchFromGitHub {
      owner = "openwrt";
      repo = "mt76";
      rev = "513c131c6309712a51502870b041f45b4bd6a6d4";
      fetchSubmodules = false;
      sha256 = "sha256-9hDO6COStU8lDU0KsC6+X1HdTNsQ2Ez4VRluFl/mIxI=";
    };
    date = "2024-05-17";
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
  prowlarr-x64 = {
    pname = "prowlarr-x64";
    version = "v1.18.0.4543/Prowlarr.master.1.18.0.4543";
    src = fetchurl {
      url = "https://github.com/Prowlarr/Prowlarr/releases/download/v1.18.0.4543/Prowlarr.master.1.18.0.4543.linux-core-x64.tar.gz";
      sha256 = "sha256-c89EiThP2LgkaeDxx01rQTtFZGcXvpMgo6yp+VViJO0=";
    };
  };
  radarr-x64 = {
    pname = "radarr-x64";
    version = "v5.6.0.8846/Radarr.master.5.6.0.8846";
    src = fetchurl {
      url = "https://github.com/Radarr/Radarr/releases/download/v5.6.0.8846/Radarr.master.5.6.0.8846.linux-core-x64.tar.gz";
      sha256 = "sha256-rKe1xQR3lkPXQBUWmKdHUu/AQ99U1kCINeXV2z/ZG5o=";
    };
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
      sha256 = "sha256-d/vQBijlw6Pe/ze0fqayWTkbzJrarFlCCM1DxpNSxvQ=";
    };
    date = "2022-11-27";
  };
  sonarr-x64 = {
    pname = "sonarr-x64";
    version = "v4.0.5.1719/Sonarr.develop.4.0.5.1719";
    src = fetchurl {
      url = "https://github.com/Sonarr/Sonarr/releases/download/v4.0.5.1719/Sonarr.develop.4.0.5.1719.linux-x64.tar.gz";
      sha256 = "sha256-YJzPhhu83TtLzjIFpSHHsASJwZhd+p8vO9Job4Fljvs=";
    };
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
  yourls-dont-log-crawlers = {
    pname = "yourls-dont-log-crawlers";
    version = "425d47d97fe913166dae4bf7054a8be6227f475b";
    src = fetchFromGitHub {
      owner = "luixxiul";
      repo = "dont-log-crawlers";
      rev = "425d47d97fe913166dae4bf7054a8be6227f475b";
      fetchSubmodules = false;
      sha256 = "sha256-VtlE1KPSFYjVR0ZMfb86cYKc27FZwJq8VU+Sb4cR62w=";
    };
    date = "2023-02-07";
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
    version = "376b586c9739b0a044192747b337f31339d548fd";
    src = fetchFromGitHub {
      owner = "hlissner";
      repo = "zsh-autopair";
      rev = "376b586c9739b0a044192747b337f31339d548fd";
      fetchSubmodules = false;
      sha256 = "sha256-mtDrt4Q5kbddydq/pT554ph0hAd5DGk9jci9auHx0z0=";
    };
    date = "2024-06-04";
  };
}
