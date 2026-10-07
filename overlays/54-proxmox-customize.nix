_: final: prev: {
  proxmox-widget-toolkit = prev.proxmox-widget-toolkit.overrideAttrs (old: {
    postFixup = (old.postFixup or "") + ''
      sed -i -e "/data\.status/ s/!//" -e "/data\.status/ s/active/NoMoreNagging/" $out/share/javascript/proxmox-widget-toolkit/proxmoxlib.js
      grep -q NoMoreNagging $out/share/javascript/proxmox-widget-toolkit/proxmoxlib.js
    '';
  });
  pve-qemu-server = prev.pve-qemu-server.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      ../patches/pve-virtiofs-force-inode-handles.patch
    ];
  });

  # Host gcc-16 emits new warnings (unused-but-set-variable in StringFuncs.c,
  # discarded-qualifiers in EfiRom.c, ...) that BaseTools' -Wall -Werror turns
  # into errors; BaseTools are host-only build tools, keep warnings but not
  # -Werror for them
  pve-edk2-firmware = prev.pve-edk2-firmware.overrideAttrs (old: {
    NIX_CFLAGS_COMPILE = (old.NIX_CFLAGS_COMPILE or "") + " -Wno-error";
  });

  # proxmox-nixos replaces the installPhase of font-awesome_4 and expects
  # css/fonts/less at the source root, but nixpkgs now sets sourceRoot
  # to source/fonts
  font-awesome_4 = prev.font-awesome_4.overrideAttrs {
    sourceRoot = "source";
  };

  # proxmox-nixos's own mimebase32 conflicts with nixpkgs MIMEBase32
  # (pulled in by URI >= 5.36) in pve-common's perl env
  mimebase32 = prev.perl5.pkgs.MIMEBase32;
}
