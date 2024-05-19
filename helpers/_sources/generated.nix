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
    version = "93ab09fc0a7a0134a9274af73a572843c480163a";
    src = fetchFromGitHub {
      owner = "walkxcode";
      repo = "dashboard-icons";
      rev = "93ab09fc0a7a0134a9274af73a572843c480163a";
      fetchSubmodules = false;
      sha256 = "sha256-o5+iKTaD5SHDuH78wYBt26jdjvtUfo5/dR2OAeBRP1I=";
    };
    date = "2024-04-07";
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
    version = "v24.04.1";
    src = fetchurl {
      url = "https://github.com/bastienwirtz/homer/releases/download/v24.04.1/homer.zip";
      sha256 = "sha256-yCfvgmVjplWSxlgwGtiyw933kP+Tmcf1oPEtQRUsUYU=";
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
  lidarr-x64 = {
    pname = "lidarr-x64";
    version = "v2.3.3.4204/Lidarr.master.2.3.3.4204";
    src = fetchurl {
      url = "https://github.com/Lidarr/Lidarr/releases/download/v2.3.3.4204/Lidarr.master.2.3.3.4204.linux-core-x64.tar.gz";
      sha256 = "sha256-ulWg9BhDr/RFE4sfXGf+i9W0KpOYKjtk49qBeIwI9dU=";
    };
  };
  llama-cpp = {
    pname = "llama-cpp";
    version = "b2929";
    src = fetchFromGitHub {
      owner = "ggerganov";
      repo = "llama.cpp";
      rev = "b2929";
      fetchSubmodules = false;
      sha256 = "sha256-hVjmEpMbGA6D03ZpJDq2nq77VQEH/6gUQQQQklvOJwo=";
    };
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
    version = "17e8150c0d7d1c206c8254e3091596b48059bea0";
    src = fetchFromGitHub {
      owner = "Womsxd";
      repo = "MihoyoBBSTools";
      rev = "17e8150c0d7d1c206c8254e3091596b48059bea0";
      fetchSubmodules = false;
      sha256 = "sha256-izaekiNxTSfaIzTfgmmqFr/csTG8A+RiL+uwKa0HzWQ=";
    };
    date = "2024-05-13";
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
    version = "a0d153ec4d445d42f2b2b7d3629337735dbcc3b2";
    src = fetchFromGitHub {
      owner = "keylase";
      repo = "nvidia-patch";
      rev = "a0d153ec4d445d42f2b2b7d3629337735dbcc3b2";
      fetchSubmodules = false;
      sha256 = "sha256-tzml1i9EtXLWCINQwWb0GHyPNE+7vCg+tLbcWO0nipU=";
    };
    date = "2024-05-10";
  };
  openvpn = {
    pname = "openvpn";
    version = "55bb3260c12bae33b6a8eac73cbb6972f8517411";
    src = fetchFromGitHub {
      owner = "OpenVPN";
      repo = "openvpn";
      rev = "55bb3260c12bae33b6a8eac73cbb6972f8517411";
      fetchSubmodules = false;
      sha256 = "sha256-MXi0ZKkmoOFGyXBpekeAzIUxE5XueSh7oaANwTrPWHE=";
    };
    date = "2024-05-16";
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
    version = "v1.17.2.4511/Prowlarr.master.1.17.2.4511";
    src = fetchurl {
      url = "https://github.com/Prowlarr/Prowlarr/releases/download/v1.17.2.4511/Prowlarr.master.1.17.2.4511.linux-core-x64.tar.gz";
      sha256 = "sha256-bYIavvea6Nwbn22CFiWXpzPGAI13oJYAIZr2FdLkyb8=";
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
    version = "v4.0.4.1668/Sonarr.develop.4.0.4.1668";
    src = fetchurl {
      url = "https://github.com/Sonarr/Sonarr/releases/download/v4.0.4.1668/Sonarr.develop.4.0.4.1668.linux-x64.tar.gz";
      sha256 = "sha256-thODsC5hb7G3gTpbtjxXsyTENRDcq/cw3vajLSoNdj0=";
    };
  };
  ulauncher-albert-calculate-anything = {
    pname = "ulauncher-albert-calculate-anything";
    version = "600aa62e82c5cdb23be58007acfc1a008e0c3c13";
    src = fetchFromGitHub {
      owner = "tchar";
      repo = "ulauncher-albert-calculate-anything";
      rev = "600aa62e82c5cdb23be58007acfc1a008e0c3c13";
      fetchSubmodules = false;
      sha256 = "sha256-ELzVPX1HhMEx0RaWSO7v8KJs4fUuWrjfZ/mskGPDguE=";
    };
    date = "2024-05-16";
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
    version = "2ec3fd3c9b950c01dbffbb2a4d191e1d34b8c58a";
    src = fetchFromGitHub {
      owner = "hlissner";
      repo = "zsh-autopair";
      rev = "2ec3fd3c9b950c01dbffbb2a4d191e1d34b8c58a";
      fetchSubmodules = false;
      sha256 = "sha256-Y7fkpvCOC/lC2CHYui+6vOdNO8dNHGrVYTGGNf9qgdg=";
    };
    date = "2024-03-08";
  };
}
