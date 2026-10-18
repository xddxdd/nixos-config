{
  config,
  lib,
  LT,
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

        # Time change
        "-a always,exit -F arch=b64 -S adjtimex -S settimeofday -k time-change"
        "-a always,exit -F arch=b32 -S adjtimex -S settimeofday -S stime -k time-change"
        "-a always,exit -F arch=b64 -S clock_settime -k time-change"
        "-a always,exit -F arch=b32 -S clock_settime -k time-change"

        # Filesystem: mounts, deletions, attribute changes
        "-a always,exit -F arch=b64 -S mount -S umount2 -k mounts"
        "-a always,exit -F arch=b32 -S mount -S umount -S umount2 -k mounts"
        "-a always,exit -F arch=b64 -S unlink -S unlinkat -S rmdir -k deletion"
        "-a always,exit -F arch=b32 -S unlink -S unlinkat -S rmdir -k deletion"
        "-a always,exit -F arch=b64 -S chmod -S fchmod -S fchmodat -k perm-mod"
        "-a always,exit -F arch=b32 -S chmod -S fchmod -S fchmodat -k perm-mod"
        "-a always,exit -F arch=b64 -S chown -S fchown -S fchownat -S lchown -k perm-mod"
        "-a always,exit -F arch=b32 -S chown -S fchown -S fchownat -S lchown -k perm-mod"

        # Privilege/identity: sudo, exec of setuid binaries, useradd/group
        "-a always,exit -F arch=b64 -S setuid -S setgid -S setreuid -S setregid -S setresuid -S setresgid -S setfsuid -S setfsgid -k identity-change"
        "-a always,exit -F arch=b32 -S setuid -S setgid -S setreuid -S setregid -S setresuid -S setresgid -S setfsuid -S setfsgid -k identity-change"
        "-a always,exit -F arch=b64 -S execve -F euid=0 -F auid>=1000 -F auid!=unset -k root-exec"
        "-a always,exit -F arch=b32 -S execve -F euid=0 -F auid>=1000 -F auid!=unset -k root-exec"
        "-a always,exit -F arch=b64 -S execve -F euid=0 -F auid=0 -F auid!=unset -k privileged-user-exec"
      ];
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
        # Controls the kernel audit subsystem over netlink
        AmbientCapabilities = [
          "CAP_AUDIT_CONTROL"
          "CAP_AUDIT_READ"
        ];
        CapabilityBoundingSet = [
          "CAP_AUDIT_CONTROL"
          "CAP_AUDIT_READ"
        ];
        PrivateUsers = false;
        ProcSubset = "all";
        ProtectProc = "default";
        SystemCallFilter = [ ];
      };
    };
  };
}