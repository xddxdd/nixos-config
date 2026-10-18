{
  config,
  lib,
  LT,
  pkgs,
  ...
}:
{
  config = {
    security.auditd.enable = lib.mkDefault true;

    security.audit = {
      enable = lib.mkDefault true;
      rules = [
        # System-wide changes
        "-w /etc/passwd -p wa -k identity"
        "-w /etc/group -p wa -k identity"
        "-w /etc/shadow -p wa -k identity"
        "-w /etc/gshadow -p wa -k identity"
        "-w /etc/sudoers -p wa -k sudoers"
        "-w /etc/sudoers.d -p wa -k sudoers"
        "-w /etc/ssh/sshd_config -p wa -k sshd-config"
        "-w /etc/ssh/sshd_config.d -p wa -k sshd-config"
        "-w /etc/systemd/system -p wa -k systemd-units"
        "-w /run/systemd/units -p wa -k systemd-runtime-units"
        "-w /etc/systemd/network -p wa -k network-config"
        "-w /etc/resolv.conf -p wa -k network-config"
        "-w /etc/hosts -p wa -k network-config"
        "-w /etc/wireguard -p wa -k network-config"
      ]
      ++ (
        if pkgs.stdenv.hostPlatform.isAarch64 then
          [
            # arm64's syscall table lacks the legacy syscalls (unlink, chmod,
            # mount-b32, stime, ...) and a single bad line makes auditctl -R
            # abort, dropping ALL later rules
            "-a always,exit -F arch=b64 -S adjtimex -S settimeofday -k time-change"
            "-a always,exit -F arch=b64 -S clock_settime -k time-change"
            "-a always,exit -F arch=b64 -S mount -S umount2 -k mounts"
            "-a always,exit -F arch=b64 -S unlinkat -S rmdir -k deletion"
            "-a always,exit -F arch=b64 -S fchmodat -k perm-mod"
            "-a always,exit -F arch=b64 -S fchown -S fchownat -k perm-mod"
            "-a always,exit -F arch=b64 -S setuid -S setgid -S setreuid -S setregid -S setresuid -S setresgid -k identity-change"
            "-a always,exit -F arch=b64 -S execve -F euid=0 -F auid>=1000 -F auid!=unset -k root-exec"
            "-a always,exit -F arch=b64 -S execve -F euid=0 -F auid=0 -F auid!=unset -k privileged-user-exec"
          ]
        else
          [
            # Time change (no stime: missing on some architectures' 32-bit
            # compat tables and fails auditctl -R, aborting all later rules)
            "-a always,exit -F arch=b64 -S adjtimex -S settimeofday -k time-change"
            "-a always,exit -F arch=b32 -S adjtimex -S settimeofday -k time-change"
            "-a always,exit -F arch=b64 -S clock_settime -k time-change"
            "-a always,exit -F arch=b32 -S clock_settime -k time-change"
            "-a always,exit -F arch=b64 -S mount -S umount2 -k mounts"
            "-a always,exit -F arch=b32 -S mount -S umount -S umount2 -k mounts"
            "-a always,exit -F arch=b64 -S unlink -S unlinkat -S rmdir -k deletion"
            "-a always,exit -F arch=b32 -S unlink -S unlinkat -S rmdir -k deletion"
            "-a always,exit -F arch=b64 -S chmod -S fchmod -S fchmodat -k perm-mod"
            "-a always,exit -F arch=b32 -S chmod -S fchmod -S fchmodat -k perm-mod"
            "-a always,exit -F arch=b64 -S chown -S fchown -S fchownat -S lchown -k perm-mod"
            "-a always,exit -F arch=b32 -S chown -S fchown -S fchownat -S lchown -k perm-mod"
            "-a always,exit -F arch=b64 -S setuid -S setgid -S setreuid -S setregid -S setresuid -S setresgid -S setfsuid -S setfsgid -k identity-change"
            "-a always,exit -F arch=b32 -S setuid -S setgid -S setreuid -S setregid -S setresuid -S setresgid -S setfsuid -S setfsgid -k identity-change"
            "-a always,exit -F arch=b64 -S execve -F euid=0 -F auid>=1000 -F auid!=unset -k root-exec"
            "-a always,exit -F arch=b32 -S execve -F euid=0 -F auid>=1000 -F auid!=unset -k root-exec"
            "-a always,exit -F arch=b64 -S execve -F euid=0 -F auid=0 -F auid!=unset -k privileged-user-exec"
          ]
      );
    };

    # auditd writes to /var/log/audit; journald picks up events through the
    # syslog plugin, which then ships to central Loki via fluent-bit
    security.auditd.settings = {
      log_file = "/var/log/audit/audit.log";
      max_log_file_action = "rotate";
      num_logs = 5;
      max_log_file = 25;
    };

    systemd.services.auditd = {
      serviceConfig = LT.serviceHarden // {
        Restart = "on-failure";
        RestartSec = "5s";
        # Controls the kernel audit subsystem over netlink; also raises its
        # own scheduling priority at startup (CAP_SYS_NICE)
        AmbientCapabilities = [
          "CAP_AUDIT_CONTROL"
          "CAP_AUDIT_READ"
          "CAP_SYS_NICE"
        ];
        CapabilityBoundingSet = [
          "CAP_AUDIT_CONTROL"
          "CAP_AUDIT_READ"
          "CAP_SYS_NICE"
        ];
        PrivateUsers = false;
        # audit netlink socket
        RestrictAddressFamilies = [ "AF_NETLINK" ];
        ProcSubset = "all";
        ProtectProc = "default";
        SystemCallFilter = [ ];
        # chroot's tmpfs root is ephemeral; bind log dir, socket dir and config
        # store files (host /etc/audit are symlink chains) through
        BindPaths = [
          "/var/log/audit"
          "/run/audit"
        ];
        BindReadOnlyPaths = lib.mapAttrsToList (n: v: "${v.source}:${n}") (
          lib.filterAttrs (n: _: lib.hasPrefix "audit/" n) config.environment.etc
        );
      };

      confinement = {
        enable = true;
        fullUnit = true;
      };
    };
  };
}
