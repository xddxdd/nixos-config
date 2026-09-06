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
}
