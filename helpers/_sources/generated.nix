# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub, dockerTools }:
{
  brlaser = {
    pname = "brlaser";
    version = "648f5c858d468a5c08136aab7dce44b2649df3f9";
    src = fetchFromGitHub {
      owner = "Owl-Maintain";
      repo = "brlaser";
      rev = "648f5c858d468a5c08136aab7dce44b2649df3f9";
      fetchSubmodules = false;
      sha256 = "sha256-35H0N6x0VAddIpDBA6k74qhPPi3VvaTNiaY/+AXDcnw=";
    };
    date = "2023-03-14";
  };
  cyberchef = {
    pname = "cyberchef";
    version = "v10.4.0";
    src = fetchurl {
      url = "https://github.com/gchq/CyberChef/releases/download/v10.4.0/CyberChef_v10.4.0.zip";
      sha256 = "sha256-hIVxO67tX87UfiVDswcgMryeVB0ZYrnug1a2Fe+gdKI=";
    };
  };
  dashboard-icons = {
    pname = "dashboard-icons";
    version = "85549dec02318c850d073dbd3a2def0abd87adc9";
    src = fetchFromGitHub {
      owner = "walkxcode";
      repo = "dashboard-icons";
      rev = "85549dec02318c850d073dbd3a2def0abd87adc9";
      fetchSubmodules = false;
      sha256 = "sha256-7QFW8qh2/Jn7wbauMgst82ZlcH1umnmUPQOnygpX5zQ=";
    };
    date = "2023-05-08";
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
    version = "v23.05.1";
    src = fetchurl {
      url = "https://github.com/bastienwirtz/homer/releases/download/v23.05.1/homer.zip";
      sha256 = "sha256-oxZjcZH1R+6vPF3ZzFKvupvpkBVHiqM3xjMyPupYEY0=";
    };
  };
  hostapd = {
    pname = "hostapd";
    version = "cc8a09a48a5c99189adff9de4f390b00e86706d2";
    src = fetchgit {
      url = "https://w1.fi/hostap.git";
      rev = "cc8a09a48a5c99189adff9de4f390b00e86706d2";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-Iab+k279mjTEJIMltijsHZRpEUzgc5yv+pPSC/dWNEM=";
    };
    date = "2023-05-04";
  };
  i915-sriov-dkms = {
    pname = "i915-sriov-dkms";
    version = "991bfa01fca3bc3794152dc57b0421814c7c2445";
    src = fetchFromGitHub {
      owner = "strongtz";
      repo = "i915-sriov-dkms";
      rev = "991bfa01fca3bc3794152dc57b0421814c7c2445";
      fetchSubmodules = false;
      sha256 = "sha256-mVQsgmOkpnv7lvPHpX1cr7lpCaz15tGg3bFJlV+3X4o=";
    };
    date = "2023-05-08";
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
    version = "e5c02f2888492e04c66ed7aeb051f17e5e9dcb3e";
    src = fetchFromGitHub {
      owner = "Womsxd";
      repo = "MihoyoBBSTools";
      rev = "e5c02f2888492e04c66ed7aeb051f17e5e9dcb3e";
      fetchSubmodules = false;
      sha256 = "sha256-miiJ+D90B3TnNAon5DMs56xFTGeV64k2JdKsysVQKfs=";
    };
    date = "2023-05-16";
  };
  nft-fullcone = {
    pname = "nft-fullcone";
    version = "47adf5d36efed16522a19936102b04ed85fa8cb9";
    src = fetchFromGitHub {
      owner = "fullcone-nat-nftables";
      repo = "nft-fullcone";
      rev = "47adf5d36efed16522a19936102b04ed85fa8cb9";
      fetchSubmodules = false;
      sha256 = "sha256-1ij/8WSyd637j1oCSgXEnEnN1KGYP6/yvPrIFUt+ucM=";
    };
    date = "2023-04-15";
  };
  nullfsvfs = {
    pname = "nullfsvfs";
    version = "v0.15";
    src = fetchFromGitHub {
      owner = "abbbi";
      repo = "nullfsvfs";
      rev = "v0.15";
      fetchSubmodules = false;
      sha256 = "sha256-VDLI/geDwZwWTLRAeEsU4WdirqjPX9mmuZLkg0EP+Aw=";
    };
  };
  nvidia-patch = {
    pname = "nvidia-patch";
    version = "b240ee53ac2f9035ee810b7f9b0b455b3876086f";
    src = fetchFromGitHub {
      owner = "keylase";
      repo = "nvidia-patch";
      rev = "b240ee53ac2f9035ee810b7f9b0b455b3876086f";
      fetchSubmodules = false;
      sha256 = "sha256-VY0XtLc0jfqoeSLD5l90tCoKpcHBkpmgNNKH6bmnVc4=";
    };
    date = "2023-05-04";
  };
  openvpn = {
    pname = "openvpn";
    version = "cf496476b364f8613bacd48e10d6a1bbbf0aceda";
    src = fetchFromGitHub {
      owner = "OpenVPN";
      repo = "openvpn";
      rev = "cf496476b364f8613bacd48e10d6a1bbbf0aceda";
      fetchSubmodules = false;
      sha256 = "sha256-E7KkavG7dAV4E3SZ2QbT1ZMTYfsOB/yTWxoE5kZ6JrY=";
    };
    date = "2023-05-13";
  };
  openwrt-mt76 = {
    pname = "openwrt-mt76";
    version = "969b7b5ebd129068ca56e4b0d831593a2f92382f";
    src = fetchFromGitHub {
      owner = "openwrt";
      repo = "mt76";
      rev = "969b7b5ebd129068ca56e4b0d831593a2f92382f";
      fetchSubmodules = false;
      sha256 = "sha256-FESdB0sk07xbWmHyc7MyG/uS1wGJc26+stOUZwZ5qoA=";
    };
    date = "2023-05-13";
  };
  ovpn-dco = {
    pname = "ovpn-dco";
    version = "961c60d0d8b8d45a21028e0479397c9c5604b81e";
    src = fetchFromGitHub {
      owner = "OpenVPN";
      repo = "ovpn-dco";
      rev = "961c60d0d8b8d45a21028e0479397c9c5604b81e";
      fetchSubmodules = false;
      sha256 = "sha256-Rl8MhWb42cJZ/rDNFss3ubkx3BRpyh/K9P8d0/pEwsY=";
    };
    date = "2023-03-28";
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
    version = "9783c7798dac82007ab85fb2d9f4185e5be104bf";
    src = fetchFromGitHub {
      owner = "dhelmr";
      repo = "ulauncher-tldr";
      rev = "9783c7798dac82007ab85fb2d9f4185e5be104bf";
      fetchSubmodules = false;
      sha256 = "sha256-3sHhU8Oknq84f584zdHA42NxZ7wCqOoqFwYtzRVvFGc=";
    };
    date = "2022-12-17";
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
