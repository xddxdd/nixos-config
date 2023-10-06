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
    version = "v10.5.2";
    src = fetchurl {
      url = "https://github.com/gchq/CyberChef/releases/download/v10.5.2/CyberChef_v10.5.2.zip";
      sha256 = "sha256-pNR6MT2eedCHdav94YoIwytQtNuPpSJhv927eFkQ0O8=";
    };
  };
  dashboard-icons = {
    pname = "dashboard-icons";
    version = "f930ee4852430fe2bb7f6d3cd048519a38149835";
    src = fetchFromGitHub {
      owner = "walkxcode";
      repo = "dashboard-icons";
      rev = "f930ee4852430fe2bb7f6d3cd048519a38149835";
      fetchSubmodules = false;
      sha256 = "sha256-8tX4zhVnmHUGauFUKM7oNXU4KBQGr1CSezriA2TeXcQ=";
    };
    date = "2023-10-01";
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
    version = "v23.09.1";
    src = fetchurl {
      url = "https://github.com/bastienwirtz/homer/releases/download/v23.09.1/homer.zip";
      sha256 = "sha256-sdL+s5trvMhN4v5bcdhV2aJEdQtHJVxJeHSzYbP/sXI=";
    };
  };
  i915-sriov-dkms = {
    pname = "i915-sriov-dkms";
    version = "58a715fa48e61a7b61b513e0553cbef630ca4c8d";
    src = fetchFromGitHub {
      owner = "strongtz";
      repo = "i915-sriov-dkms";
      rev = "58a715fa48e61a7b61b513e0553cbef630ca4c8d";
      fetchSubmodules = false;
      sha256 = "sha256-xzMTrYn057F5upQk6Kukq156gbZEllIBppMjXB1oX8o=";
    };
    date = "2023-09-19";
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
    version = "69edad05ff9d2136790ceff1a92c1be19810655d";
    src = fetchFromGitHub {
      owner = "Womsxd";
      repo = "MihoyoBBSTools";
      rev = "69edad05ff9d2136790ceff1a92c1be19810655d";
      fetchSubmodules = false;
      sha256 = "sha256-S2kcRa+Gj7nfyGRSce936gmGCQJ5Z2RPgaTrGJDEc+Q=";
    };
    date = "2023-09-23";
  };
  nft-fullcone = {
    pname = "nft-fullcone";
    version = "07d93b626ce5ea885cd16f9ab07fac3213c355d9";
    src = fetchFromGitHub {
      owner = "fullcone-nat-nftables";
      repo = "nft-fullcone";
      rev = "07d93b626ce5ea885cd16f9ab07fac3213c355d9";
      fetchSubmodules = false;
      sha256 = "sha256-PJHKt7w72lYFAb2OSswX7QyLnSY0jB93DkBxGk8AwD4=";
    };
    date = "2023-05-17";
  };
  nullfsvfs = {
    pname = "nullfsvfs";
    version = "v0.16";
    src = fetchFromGitHub {
      owner = "abbbi";
      repo = "nullfsvfs";
      rev = "v0.16";
      fetchSubmodules = false;
      sha256 = "sha256-hmmH5bPk3ZgMLobnsMXMtz8yy33jWDfOcxtfSoOgjaw=";
    };
  };
  nvidia-patch = {
    pname = "nvidia-patch";
    version = "2bd1fcb5211ff8d01ccdbe50872e2f32c9498fdc";
    src = fetchFromGitHub {
      owner = "keylase";
      repo = "nvidia-patch";
      rev = "2bd1fcb5211ff8d01ccdbe50872e2f32c9498fdc";
      fetchSubmodules = false;
      sha256 = "sha256-U8UQjRnQthcEJ6Amz6Q/14g6n/uZnIAf3O4uG9ia5FY=";
    };
    date = "2023-10-03";
  };
  openvpn = {
    pname = "openvpn";
    version = "2671dcb69837ae58b3303f11c1b6ba4cee8eea00";
    src = fetchFromGitHub {
      owner = "OpenVPN";
      repo = "openvpn";
      rev = "2671dcb69837ae58b3303f11c1b6ba4cee8eea00";
      fetchSubmodules = false;
      sha256 = "sha256-b5AOSRG8PKHFVjZF9uWFOIwstBGkDmIrl/jA1qcqWQ8=";
    };
    date = "2023-10-02";
  };
  openwrt-mt76 = {
    pname = "openwrt-mt76";
    version = "4a0f839da0f108837baad908ed12b550f493b912";
    src = fetchFromGitHub {
      owner = "openwrt";
      repo = "mt76";
      rev = "4a0f839da0f108837baad908ed12b550f493b912";
      fetchSubmodules = false;
      sha256 = "sha256-u4sIJMlSyff/FLxsn1C+hMDfxmlgjItBXWGFt20aMp4=";
    };
    date = "2023-09-30";
  };
  ovpn-dco = {
    pname = "ovpn-dco";
    version = "dba96d203f960356b477291d6a58d30fc096fbe4";
    src = fetchFromGitHub {
      owner = "OpenVPN";
      repo = "ovpn-dco";
      rev = "dba96d203f960356b477291d6a58d30fc096fbe4";
      fetchSubmodules = false;
      sha256 = "sha256-DpguXHrVLJpvl9leFRtpsHnxx8VyQ2ZIHcYSYRz2iGE=";
    };
    date = "2023-08-16";
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
  ulauncher-albert-calculate-anything = {
    pname = "ulauncher-albert-calculate-anything";
    version = "ee0903174c8b87cd1f7c3b6c1acef10702547507";
    src = fetchFromGitHub {
      owner = "tchar";
      repo = "ulauncher-albert-calculate-anything";
      rev = "ee0903174c8b87cd1f7c3b6c1acef10702547507";
      fetchSubmodules = false;
      sha256 = "sha256-qpnU7yjRPqEdu8HFncACmofxOFOFENazCp3Cuw0/HE4=";
    };
    date = "2021-08-12";
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
    version = "4c6af50d1c9a24d5aad2c597634ff0c634972a5c";
    src = fetchFromGitHub {
      owner = "Ulauncher";
      repo = "ulauncher-emoji";
      rev = "4c6af50d1c9a24d5aad2c597634ff0c634972a5c";
      fetchSubmodules = false;
      sha256 = "sha256-VIWmv+vFByYS3VRuXqWOOORRu+zson+xOYg7havYM14=";
    };
    date = "2021-08-08";
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
    version = "610dc19a6bab76fd9438e1059aba849201a4a4aa";
    src = fetchFromGitHub {
      owner = "plibither8";
      repo = "ulauncher-vscode-recent";
      rev = "610dc19a6bab76fd9438e1059aba849201a4a4aa";
      fetchSubmodules = false;
      sha256 = "sha256-HgRC27BjY7q7i/bwu4aH00rC9uDszP1QuF4Qtg7mDpM=";
    };
    date = "2022-05-19";
  };
  web-compressor = {
    pname = "web-compressor";
    version = "931a0a185c1e4268a668c43920af512631c740b4";
    src = fetchFromGitHub {
      owner = "xddxdd";
      repo = "web-compressor";
      rev = "931a0a185c1e4268a668c43920af512631c740b4";
      fetchSubmodules = false;
      sha256 = "sha256-qyR34BXVubkvRB/47alkQ/b0K7ldLlU67CY2lxkwYDU=";
    };
    date = "2023-09-23";
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
    version = "eaff0956b29ea869f39613211f0070bc047e3345";
    src = fetchFromGitHub {
      owner = "YOURLS";
      repo = "404-if-not-found";
      rev = "eaff0956b29ea869f39613211f0070bc047e3345";
      fetchSubmodules = false;
      sha256 = "sha256-6RzNZjt1YrN/gGJdWSWEc0dyBqrKTq/6Nwso1MOEwQM=";
    };
    date = "2022-04-22";
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
    version = "396c38a7468458ba29011f2ad4112e4fd35f78e6";
    src = fetchFromGitHub {
      owner = "hlissner";
      repo = "zsh-autopair";
      rev = "396c38a7468458ba29011f2ad4112e4fd35f78e6";
      fetchSubmodules = false;
      sha256 = "sha256-PXHxPxFeoYXYMOC29YQKDdMnqTO0toyA7eJTSCV6PGE=";
    };
    date = "2022-10-03";
  };
}
