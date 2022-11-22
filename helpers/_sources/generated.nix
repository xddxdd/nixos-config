# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub }:
{
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
  material-kwin-decoration = {
    pname = "material-kwin-decoration";
    version = "973949761f609f9c676c5b2b7c6d9560661d34c3";
    src = fetchFromGitHub ({
      owner = "Zren";
      repo = "material-decoration";
      rev = "973949761f609f9c676c5b2b7c6d9560661d34c3";
      fetchSubmodules = false;
      sha256 = "sha256-n+yUmBUrkS+06qLnzl2P6CTQZZbDtJLy+2mDPCcQz9M=";
    });
  };
  nullfsvfs = {
    pname = "nullfsvfs";
    version = "v0.13";
    src = fetchFromGitHub ({
      owner = "abbbi";
      repo = "nullfsvfs";
      rev = "v0.13";
      fetchSubmodules = false;
      sha256 = "sha256-yn9FPlruJiCKO6tJWvFNJpABHlW/EQf2i/iDKRchRds=";
    });
  };
  nvidia-patch = {
    pname = "nvidia-patch";
    version = "5db98c1d6cbccf63fe0841ac5544148f315f3e9d";
    src = fetchFromGitHub ({
      owner = "keylase";
      repo = "nvidia-patch";
      rev = "5db98c1d6cbccf63fe0841ac5544148f315f3e9d";
      fetchSubmodules = false;
      sha256 = "sha256-3ECUEx6WeOFG+0PB2Pus9SvmIBhiBr5qBhdCu9oKlO0=";
    });
  };
  openvpn = {
    pname = "openvpn";
    version = "543f709f13bca9887cabd4545554539f18346e3c";
    src = fetchFromGitHub ({
      owner = "OpenVPN";
      repo = "openvpn";
      rev = "543f709f13bca9887cabd4545554539f18346e3c";
      fetchSubmodules = false;
      sha256 = "sha256-dH9aDB9NyZY+d69buXf7iZVePJGfw+4zal401fFU4LE=";
    });
  };
  ovpn-dco = {
    pname = "ovpn-dco";
    version = "d1d53564e17d807aed2b945ea3d4ec35bdd9f09b";
    src = fetchFromGitHub ({
      owner = "OpenVPN";
      repo = "ovpn-dco";
      rev = "d1d53564e17d807aed2b945ea3d4ec35bdd9f09b";
      fetchSubmodules = false;
      sha256 = "sha256-ZP7pwcAyFdV3T7UqksnhhPAIoSaCkwnzQsIuhy8s54g=";
    });
  };
  transmission-web-control = {
    pname = "transmission-web-control";
    version = "0bbe64d28667a72130aded6e6d6826efa68566ad";
    src = fetchFromGitHub ({
      owner = "ronggang";
      repo = "transmission-web-control";
      rev = "0bbe64d28667a72130aded6e6d6826efa68566ad";
      fetchSubmodules = false;
      sha256 = "sha256-JMgrbnf6fe3rRO8oWQabchYrUPobwqGJPnbutUtOewU=";
    });
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
  };
  ulauncher-tldr = {
    pname = "ulauncher-tldr";
    version = "2ad5d29963db649775f68a7815af18509f4c287f";
    src = fetchFromGitHub ({
      owner = "dhelmr";
      repo = "ulauncher-tldr";
      rev = "2ad5d29963db649775f68a7815af18509f4c287f";
      fetchSubmodules = false;
      sha256 = "sha256-NRNRhxzjzw2RTIrU8RZMMYlJQ7m+KC4PxpscJvpL2A8=";
    });
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
  };
}
