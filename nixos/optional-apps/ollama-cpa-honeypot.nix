{
  pkgs,
  lib,
  LT,
  ...
}:
{
  imports = [ ./postgresql.nix ];

  services.postgresql = {
    ensureDatabases = [ "ollama-cpa-honeypot" ];
    ensureUsers = [
      {
        name = "ollama-cpa-honeypot";
        ensureDBOwnership = true;
      }
    ];
  };

  users.users.ollama-cpa-honeypot = {
    group = "ollama-cpa-honeypot";
    isSystemUser = true;
  };
  users.groups.ollama-cpa-honeypot = { };

  systemd.services.ollama-cpa-honeypot = {
    description = "Ollama and CLIProxyAPI HTTP honeypot";
    after = [
      "network.target"
      "postgresql.service"
    ];
    requires = [ "postgresql.service" ];
    wantedBy = [ "multi-user.target" ];

    # sys1's auto-responder downloads its model via hf-hub; HF_HOME honours the
    # HF cache root, XDG_CACHE_HOME covers dirs::cache_dir() fallbacks.
    environment = {
      HF_HOME = "/var/lib/ollama-cpa-honeypot/hf-home";
      XDG_CACHE_HOME = "/var/lib/ollama-cpa-honeypot/cache";
      # App defaults to "info" via tracing EnvFilter
      RUST_LOG = "warn";
    };

    serviceConfig = LT.serviceHarden // {
      # Peer auth via unix socket requires system user == database user
      ExecStart = "${lib.getExe pkgs.ollama-cpa-honeypot} --bind ${LT.this.ltnet.IPv4} --ollama-port ${LT.portStr.OllamaCpaHoneypot.Ollama} --cpa-port ${LT.portStr.OllamaCpaHoneypot.Cpa} --database postgres --database-url 'postgres:///ollama-cpa-honeypot?host=/run/postgresql&user=ollama-cpa-honeypot' --trust-proxy-headers";
      User = "ollama-cpa-honeypot";
      Group = "ollama-cpa-honeypot";
      StateDirectory = "ollama-cpa-honeypot";
      Restart = "always";
      RestartSec = "5s";
    };
  };
}
