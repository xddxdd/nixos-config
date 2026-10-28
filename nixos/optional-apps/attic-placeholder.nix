_: {
  lantian.nginxVhosts = {
    "attic.xuyh0120.win" = {
      locations = {
        "/".return =
          "400 'Binary cache migrated: https://github.com/xddxdd/nix-cachyos-kernel/issues/110#issuecomment-6386974695'";
      };

      sslCertificate = "lets-encrypt-xuyh0120.win";
      noIndex.enable = true;
    };
  };
}
