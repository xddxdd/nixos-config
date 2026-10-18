_: {
  lantian.nginxVhosts = {
    "attic.xuyh0120.win" = {
      locations = {
        "/".return =
          "503 'Binary cache unavailable due to server compromise: https://github.com/xddxdd/nix-cachyos-kernel/issues/110'";
      };

      sslCertificate = "lets-encrypt-xuyh0120.win";
      noIndex.enable = true;
    };
  };
}
