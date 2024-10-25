{
  lib,
  config,
  ...
}:
# Hardening adapted from https://github.com/cynicsketch/nix-mineral/blob/main/nix-mineral.nix
{
  boot.specialFileSystems = {
    "/dev/shm".options = [ "noexec" ];
    "/run".options = [ "noexec" ];
    "/dev".options = [ "noexec" ];
  };

  # Empty /etc/securetty to prevent root login on tty.
  environment.etc.securetty.text = ''
    # /etc/securetty: list of terminals on which root is allowed to login.
    # See securetty(5) and login(1).
  '';

  security.protectKernelImage = true;
  security.sudo.enable = lib.mkForce false;
  security.sudo-rs = {
    enable = true;
    execWheelOnly = true;
    wheelNeedsPassword = false;
  };

  security.pam.loginLimits = [
    {
      domain = "@wheel";
      item = "nproc";
      type = "-";
      value = "5000000";
    }
  ];

  security.pam.services = {
    # Increase hashing rounds for /etc/shadow; this doesn't automatically
    # rehash your passwords, you'll need to set passwords for your accounts
    # again for this to work.
    passwd.text = ''
      password required pam_unix.so sha512 shadow nullok rounds=65536
    '';

    # Enable PAM support for securetty, to prevent root login.
    # https://unix.stackexchange.com/questions/670116/debian-bullseye-disable-console-tty-login-for-root
    login.text = lib.mkDefault (
      lib.mkBefore ''
        # Enable securetty support.
        auth       requisite  pam_nologin.so
        auth       requisite  pam_securetty.so
      ''
    );

    su.requireWheel = true;
    su-l.requireWheel = true;
    system-login.failDelay.delay = "5000000";
  };

  # Get extra entropy since we disabled hardware entropy sources
  # Read more about why at the following URLs:
  # https://github.com/smuellerDD/jitterentropy-rngd/issues/27
  # https://blogs.oracle.com/linux/post/rngd1
  services.jitterentropy-rngd.enable = true;
  boot.kernelModules = [ "jitterentropy_rng" ];

  # zram allows swapping to RAM by compressing memory. This reduces the chance
  # that sensitive data is written to disk, and eliminates it if zram is used
  # to completely replace swap to disk. Generally *improves* storage lifespan
  # and performance, there usually isn't a need to disable this.
  zramSwap = {
    enable = !config.boot.isContainer;
    algorithm = "zstd";
    memoryPercent = 50;
  };
}
