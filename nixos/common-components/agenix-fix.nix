{ pkgs, lib, config, ... }:

let
  cfg = config.age;
in
{
  system.activationScripts.agenixMountSecrets.text = lib.mkForce ''
    _agenix_generation="$(basename "$(readlink ${cfg.secretsDir})" || echo 0)"
    (( ++_agenix_generation ))
    echo "[agenix] symlinking new secrets to ${cfg.secretsDir} (generation $_agenix_generation)..."
    mkdir -p "${cfg.secretsMountPoint}"
    chmod 0751 "${cfg.secretsMountPoint}"
    grep -q "ramfs" /proc/filesystems && {
      grep -q "${cfg.secretsMountPoint} ramfs" /proc/mounts || mount -t ramfs none "${cfg.secretsMountPoint}" -o nodev,nosuid,mode=0751
    } || {
      grep -q "${cfg.secretsMountPoint} tmpfs" /proc/mounts || mount -t tmpfs none "${cfg.secretsMountPoint}" -o nodev,nosuid,mode=0751
    }
    mkdir -p "${cfg.secretsMountPoint}/$_agenix_generation"
    chmod 0751 "${cfg.secretsMountPoint}/$_agenix_generation"
    ln -sfn "${cfg.secretsMountPoint}/$_agenix_generation" ${cfg.secretsDir}
    (( _agenix_generation > 1 )) && {
      echo "[agenix] removing old secrets (generation $(( _agenix_generation - 1 )))..."
      rm -rf "${cfg.secretsMountPoint}/$(( _agenix_generation - 1 ))"
    }
  '';
}
