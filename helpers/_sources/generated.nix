# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub, dockerTools }:
{
  brlaser = {
    pname = "brlaser";
    version = "648f5c858d468a5c08136aab7dce44b2649df3f9";
    src = fetchFromGitHub ({
      owner = "Owl-Maintain";
      repo = "brlaser";
      rev = "648f5c858d468a5c08136aab7dce44b2649df3f9";
      fetchSubmodules = false;
      sha256 = "sha256-35H0N6x0VAddIpDBA6k74qhPPi3VvaTNiaY/+AXDcnw=";
    });
    date = "2023-03-14";
  };
  himawaripy = {
    pname = "himawaripy";
    version = "v2.2.0";
    src = fetchFromGitHub ({
      owner = "boramalper";
      repo = "himawaripy";
      rev = "v2.2.0";
      fetchSubmodules = false;
      sha256 = "sha256-GcHFB851ClQjFjqTMZbRuGdg4kWjAnou9w9l+UDYM5c=";
    });
  };
  hostapd = {
    pname = "hostapd";
    version = "4e86692ff18b7b7f037cad6795325c2e3b989873";
    src = fetchgit {
      url = "https://w1.fi/hostap.git";
      rev = "4e86692ff18b7b7f037cad6795325c2e3b989873";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-VH307K6+ZHPVukH52lw4qwkx8ktPIlssQHBg3mqVQ2w=";
    };
    date = "2023-03-09";
  };
  i915-sriov-dkms = {
    pname = "i915-sriov-dkms";
    version = "10709e39edde863798cb5a728ea9794843d04b93";
    src = fetchFromGitHub ({
      owner = "strongtz";
      repo = "i915-sriov-dkms";
      rev = "10709e39edde863798cb5a728ea9794843d04b93";
      fetchSubmodules = false;
      sha256 = "sha256-oXg0mt/Aa/TFDmRd66Y+2+b/K0MO26ln557/IyRNPA0=";
    });
    date = "2023-03-08";
  };
  material-kwin-decoration = {
    pname = "material-kwin-decoration";
    version = "0e989e5b815b64ee5bca989f983da68fa5556644";
    src = fetchFromGitHub ({
      owner = "Zren";
      repo = "material-decoration";
      rev = "0e989e5b815b64ee5bca989f983da68fa5556644";
      fetchSubmodules = false;
      sha256 = "sha256-Ncn5jxkuN4ZBWihfycdQwpJ0j4sRpBGMCl6RNiH4mXg=";
    });
    date = "2023-01-15";
  };
  nft-fullcone = {
    pname = "nft-fullcone";
    version = "5a21ca29b7da429174951d1801a9681a25982d10";
    src = fetchFromGitHub ({
      owner = "fullcone-nat-nftables";
      repo = "nft-fullcone";
      rev = "5a21ca29b7da429174951d1801a9681a25982d10";
      fetchSubmodules = false;
      sha256 = "sha256-DpbLiNtS0sY0gEnGImQ84/5GXGtwMdd6/K6JNJaFkow=";
    });
    date = "2023-02-26";
  };
  nullfsvfs = {
    pname = "nullfsvfs";
    version = "v0.15";
    src = fetchFromGitHub ({
      owner = "abbbi";
      repo = "nullfsvfs";
      rev = "v0.15";
      fetchSubmodules = false;
      sha256 = "sha256-VDLI/geDwZwWTLRAeEsU4WdirqjPX9mmuZLkg0EP+Aw=";
    });
  };
  nvidia-patch = {
    pname = "nvidia-patch";
    version = "6c974eaa04b28e84ad26e532a77b085b223083bb";
    src = fetchFromGitHub ({
      owner = "keylase";
      repo = "nvidia-patch";
      rev = "6c974eaa04b28e84ad26e532a77b085b223083bb";
      fetchSubmodules = false;
      sha256 = "sha256-zmeVMxHz1A3myBn8AlUhJwol16UmbkHZH/Zx71YzKlg=";
    });
    date = "2023-03-14";
  };
  openvpn = {
    pname = "openvpn";
    version = "fe0853d2e72dd3a639a95e420ad7eeed6b49e81b";
    src = fetchFromGitHub ({
      owner = "OpenVPN";
      repo = "openvpn";
      rev = "fe0853d2e72dd3a639a95e420ad7eeed6b49e81b";
      fetchSubmodules = false;
      sha256 = "sha256-4U3qApt3ELr9BZ0k+6XeRnzBT/9mJ4zh8z7npy4V33Y=";
    });
    date = "2023-03-13";
  };
  ovpn-dco = {
    pname = "ovpn-dco";
    version = "0a5fa0a69b51af666deb657e5ff19ac6e499b0fd";
    src = fetchFromGitHub ({
      owner = "OpenVPN";
      repo = "ovpn-dco";
      rev = "0a5fa0a69b51af666deb657e5ff19ac6e499b0fd";
      fetchSubmodules = false;
      sha256 = "sha256-yIPEYjDYIwqm8ftBMK/GSimV/N05in++2vrLFpYm5ps=";
    });
    date = "2023-03-09";
  };
  ulauncher-albert-calculate-anything = {
    pname = "ulauncher-albert-calculate-anything";
    version = "ee0903174c8b87cd1f7c3b6c1acef10702547507";
    src = fetchFromGitHub ({
      owner = "tchar";
      repo = "ulauncher-albert-calculate-anything";
      rev = "ee0903174c8b87cd1f7c3b6c1acef10702547507";
      fetchSubmodules = false;
      sha256 = "sha256-qpnU7yjRPqEdu8HFncACmofxOFOFENazCp3Cuw0/HE4=";
    });
    date = "2021-08-12";
  };
  ulauncher-colorconverter = {
    pname = "ulauncher-colorconverter";
    version = "2d5e2bc17e89f1f1dc561f73e68ea574e0be844a";
    src = fetchFromGitHub ({
      owner = "sergius02";
      repo = "ulauncher-colorconverter";
      rev = "2d5e2bc17e89f1f1dc561f73e68ea574e0be844a";
      fetchSubmodules = false;
      sha256 = "sha256-UfRU7BpQUj26THzE8kYLIRUfe7voGvAcGDBTsl+yCwU=";
    });
    date = "2020-12-06";
  };
  ulauncher-emoji = {
    pname = "ulauncher-emoji";
    version = "4c6af50d1c9a24d5aad2c597634ff0c634972a5c";
    src = fetchFromGitHub ({
      owner = "Ulauncher";
      repo = "ulauncher-emoji";
      rev = "4c6af50d1c9a24d5aad2c597634ff0c634972a5c";
      fetchSubmodules = false;
      sha256 = "sha256-VIWmv+vFByYS3VRuXqWOOORRu+zson+xOYg7havYM14=";
    });
    date = "2021-08-08";
  };
  ulauncher-meme-my-text = {
    pname = "ulauncher-meme-my-text";
    version = "5d62830a7a92983a731e15645831f53d48dad913";
    src = fetchFromGitHub ({
      owner = "RNairn01";
      repo = "ulauncher-meme-my-text";
      rev = "5d62830a7a92983a731e15645831f53d48dad913";
      fetchSubmodules = false;
      sha256 = "sha256-vIWIl2qOWYVrCLhGoDXH4xTfhc+GhE9cVFuV1qjYaH0=";
    });
    date = "2021-05-07";
  };
  ulauncher-tldr = {
    pname = "ulauncher-tldr";
    version = "9783c7798dac82007ab85fb2d9f4185e5be104bf";
    src = fetchFromGitHub ({
      owner = "dhelmr";
      repo = "ulauncher-tldr";
      rev = "9783c7798dac82007ab85fb2d9f4185e5be104bf";
      fetchSubmodules = false;
      sha256 = "sha256-3sHhU8Oknq84f584zdHA42NxZ7wCqOoqFwYtzRVvFGc=";
    });
    date = "2022-12-17";
  };
  ulauncher-virtualbox = {
    pname = "ulauncher-virtualbox";
    version = "d8f495df3c7f41ee8493b207d17f06fc0372c84e";
    src = fetchFromGitHub ({
      owner = "luispabon";
      repo = "ulauncher-virtualbox";
      rev = "d8f495df3c7f41ee8493b207d17f06fc0372c84e";
      fetchSubmodules = false;
      sha256 = "sha256-IT1qsXpwYkl5vKGEBI9WySpWm6zOfe9ewj5oNgC8/Ro=";
    });
    date = "2020-09-23";
  };
  ulauncher-vscode-recent = {
    pname = "ulauncher-vscode-recent";
    version = "610dc19a6bab76fd9438e1059aba849201a4a4aa";
    src = fetchFromGitHub ({
      owner = "plibither8";
      repo = "ulauncher-vscode-recent";
      rev = "610dc19a6bab76fd9438e1059aba849201a4a4aa";
      fetchSubmodules = false;
      sha256 = "sha256-HgRC27BjY7q7i/bwu4aH00rC9uDszP1QuF4Qtg7mDpM=";
    });
    date = "2022-05-19";
  };
  yourls = {
    pname = "yourls";
    version = "1.9.2";
    src = fetchFromGitHub ({
      owner = "YOURLS";
      repo = "YOURLS";
      rev = "1.9.2";
      fetchSubmodules = false;
      sha256 = "sha256-eV8TMWa4woIjRJhuptS7MDVdgItOo5towjKYNlruIKo=";
    });
  };
  yourls-404-if-not-found = {
    pname = "yourls-404-if-not-found";
    version = "eaff0956b29ea869f39613211f0070bc047e3345";
    src = fetchFromGitHub ({
      owner = "YOURLS";
      repo = "404-if-not-found";
      rev = "eaff0956b29ea869f39613211f0070bc047e3345";
      fetchSubmodules = false;
      sha256 = "sha256-6RzNZjt1YrN/gGJdWSWEc0dyBqrKTq/6Nwso1MOEwQM=";
    });
    date = "2022-04-22";
  };
  yourls-always-302 = {
    pname = "yourls-always-302";
    version = "c704f3d285fae60e0c49445c499a5bf4b235d411";
    src = fetchFromGitHub ({
      owner = "tinjaw";
      repo = "Always-302";
      rev = "c704f3d285fae60e0c49445c499a5bf4b235d411";
      fetchSubmodules = false;
      sha256 = "sha256-llZagwjVWSXCupIzDQ90Rid6icKQ3PL5xoqIC0NzImg=";
    });
    date = "2020-08-22";
  };
  yourls-dont-log-crawlers = {
    pname = "yourls-dont-log-crawlers";
    version = "425d47d97fe913166dae4bf7054a8be6227f475b";
    src = fetchFromGitHub ({
      owner = "luixxiul";
      repo = "dont-log-crawlers";
      rev = "425d47d97fe913166dae4bf7054a8be6227f475b";
      fetchSubmodules = false;
      sha256 = "sha256-VtlE1KPSFYjVR0ZMfb86cYKc27FZwJq8VU+Sb4cR62w=";
    });
    date = "2023-02-07";
  };
  yourls-dont-track-admins = {
    pname = "yourls-dont-track-admins";
    version = "be87e385a52fb452d6b8c70e9fc28ca060a63f62";
    src = fetchFromGitHub ({
      owner = "dgw";
      repo = "yourls-dont-track-admins";
      rev = "be87e385a52fb452d6b8c70e9fc28ca060a63f62";
      fetchSubmodules = false;
      sha256 = "sha256-GWCUpxPfD/bqwGS1Rhu12HVDK7hgQVCv2mlcI5OOvUg=";
    });
    date = "2022-05-30";
  };
  yourls-login-timeout = {
    pname = "yourls-login-timeout";
    version = "1a8eee5a5104c15660952abc49b79486d81917c6";
    src = fetchFromGitHub ({
      owner = "reanimus";
      repo = "yourls-login-timeout";
      rev = "1a8eee5a5104c15660952abc49b79486d81917c6";
      fetchSubmodules = false;
      sha256 = "sha256-YGz09e2Fd9R1LcXVIGSjvlF7Hzn6KLB2ZiTL/jPlkSA=";
    });
    date = "2019-04-01";
  };
  yourls-sleeky = {
    pname = "yourls-sleeky";
    version = "f7978d9d426e4373a02785c5c008920f4bec7a96";
    src = fetchFromGitHub ({
      owner = "Flynntes";
      repo = "Sleeky";
      rev = "f7978d9d426e4373a02785c5c008920f4bec7a96";
      fetchSubmodules = false;
      sha256 = "sha256-Y8w9awNm1s3FpNRrwhCvyvDj4hg51GAKzcWKOoOnipA=";
    });
    date = "2021-06-27";
  };
  zsh-autopair = {
    pname = "zsh-autopair";
    version = "396c38a7468458ba29011f2ad4112e4fd35f78e6";
    src = fetchFromGitHub ({
      owner = "hlissner";
      repo = "zsh-autopair";
      rev = "396c38a7468458ba29011f2ad4112e4fd35f78e6";
      fetchSubmodules = false;
      sha256 = "sha256-PXHxPxFeoYXYMOC29YQKDdMnqTO0toyA7eJTSCV6PGE=";
    });
    date = "2022-10-03";
  };
}
