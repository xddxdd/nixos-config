{
  pkgs,
  lib,
  LT,
  config,
  inputs,
  ...
}@args:
let
  glauthUsers = import (inputs.secrets + "/glauth-users.nix");
in
{
  imports = [ ../postgresql.nix ];

  age.secrets.glauth-bindpw = {
    file = inputs.secrets + "/glauth-bindpw.age";
    mode = "0444";
  };

  services.matrix-synapse = {
    enable = true;
    enableRegistrationScript = false;

    plugins = with config.services.matrix-synapse.package.plugins; [
      matrix-http-rendezvous-synapse
      matrix-synapse-ldap3
      matrix-synapse-mjolnir-antispam
    ];

    settings = {
      public_baseurl = "https://matrix.lantian.pub";
      server_name = config.networking.domain;
      account_threepid_delegates = {
        msisdn = "https://vector.im";
      };
      database = {
        args.user = "matrix-synapse";
        args.database = "matrix-synapse";
        name = "psycopg2";
      };
      listeners = [
        # Client API must be on main process for admin API
        {
          path = "/run/matrix-synapse/client.sock";
          type = "http";
          resources = [
            {
              names = [ "client" ];
              compress = false;
            }
          ];
        }
        {
          path = "/run/matrix-synapse/federation.sock";
          type = "http";
          resources = [
            {
              names = [ "federation" ];
              compress = false;
            }
          ];
        }
      ];

      ip_range_blacklist = LT.constants.reserved.IPv4 ++ LT.constants.reserved.IPv6;
      ip_range_whitelist =
        LT.constants.dn42.IPv4
        ++ LT.constants.dn42.IPv6
        ++ LT.constants.neonetwork.IPv4
        ++ LT.constants.neonetwork.IPv6;
      admin_contact = glauthUsers.lantian.mail;

      forgotten_room_retention_period = "7d";

      enable_media_repo = true;
      media_store_path = "${config.services.matrix-synapse.dataDir}/media";
      media_storage_providers = [
        {
          module = "file_system";
          store_local = false;
          store_remote = true;
          store_synchronous = true;
          config.directory = "${config.services.matrix-synapse.dataDir}/remote-media";
        }
      ];
      max_upload_size = "500M";
      dynamic_thumbnails = true;
      url_preview_enabled = true;
      url_preview_ip_range_blacklist = LT.constants.reserved.IPv4 ++ LT.constants.reserved.IPv6;
      url_preview_ip_range_whitelist =
        LT.constants.dn42.IPv4
        ++ LT.constants.dn42.IPv6
        ++ LT.constants.neonetwork.IPv4
        ++ LT.constants.neonetwork.IPv6;
      remote_media_download_burst_count = "1G";
      remote_media_download_per_second = "1G";

      modules = [
        {
          module = "matrix_http_rendezvous_synapse.SynapseRendezvousModule";
          config.prefix = "/_synapse/client/org.matrix.msc3886/rendezvous";
        }
        {
          module = "ldap_auth_provider.LdapAuthProviderModule";
          config = {
            enabled = true;
            uri = "ldap://[fdbc:f9dc:67ad:2547::389]:${LT.portStr.LDAP}";
            base = "dc=lantian,dc=pub";
            attributes = {
              uid = "cn";
              mail = "mail";
              name = "givenName";
            };
          };
          bind_dn = "cn=serviceuser,dc=lantian,dc=pub";
          bind_password_file = config.age.secrets.glauth-bindpw.path;
          filter = "(&(objectClass=posixAccount)(!(ou=svcaccts)))";
        }
        {
          module = "mjolnir.Module";
          config = {
            block_invites = true;
            block_messages = false;
            block_usernames = false;
            ban_lists = [ ];
          };
        }
      ];

      experimental_features = {
        msc3886_endpoint = "/_synapse/client/org.matrix.msc3886/rendezvous";
      };

      # Increase rate limit
      rc_admin_redaction = {
        per_second = 100;
        burst_count = 100;
      };
      rc_joins = {
        local = {
          per_second = 1;
          burst_count = 10;
        };
        remote = {
          per_second = 1;
          burst_count = 10;
        };
      };
      rc_joins_per_room = {
        per_second = 1;
        burst_count = 10;
      };
      rc_login = {
        address = {
          per_second = 1;
          burst_count = 5;
        };
        account = {
          per_second = 1;
          burst_count = 5;
        };
        failed_attempts = {
          per_second = 3.0e-3;
          burst_count = 3;
        };
      };
      rc_message = {
        per_second = 5;
        burst_count = 10;
      };

      # https://www.metered.ca/tools/openrelay/
      turn_uris = [
        "turn:staticauth.openrelay.metered.ca:80?transport=udp"
        "turn:staticauth.openrelay.metered.ca:80?transport=tcp"
        "turns:staticauth.openrelay.metered.ca:443?transport=udp"
        "turns:staticauth.openrelay.metered.ca:443?transport=tcp"
      ];
      turn_shared_secret = "openrelayprojectsecret";
      turn_user_lifetime = 86400000;
      turn_allow_guests = true;
    };
  };

  users.groups.matrix-synapse.members = [ "nginx" ];

  systemd.services.matrix-synapse = {
    environment = {
      LD_PRELOAD = lib.mkForce "${pkgs.mimalloc}/lib/libmimalloc.so";
      SYNAPSE_ASYNC_IO_REACTOR = "1";
    };
    serviceConfig = LT.serviceHarden // {
      MemoryDenyWriteExecute = false;
      StateDirectory = "matrix-synapse";
      RuntimeDirectory = "matrix-synapse";
      RuntimeDirectoryPreserve = lib.mkForce false;
    };
  };

  services.postgresql = {
    ensureDatabases = [ "matrix-synapse" ];
    ensureUsers = [
      {
        name = "matrix-synapse";
        ensureDBOwnership = true;
      }
    ];
  };

  lantian.nginxVhosts."matrix-federation.lantian.pub" = {
    listenHTTPS.port = LT.port.Matrix.Public;

    serverAliases = [
      "matrix.lantian.pub"
      config.services.matrix-synapse.settings.server_name
    ];
    locations = {
      "/" = {
        proxyPass = "http://unix:/run/matrix-synapse/federation.sock";
        proxyWebsockets = true;
        proxyNoTimeout = true;
      };
    };

    sslCertificate = "zerossl-lantian.pub";
    noIndex.enable = true;
  };

  lantian.nginxVhosts."matrix-client.lantian.pub" = {
    serverAliases = [ "matrix.lantian.pub" ];
    locations = {
      "/" = {
        proxyPass = "http://unix:/run/matrix-synapse/client.sock";
        proxyWebsockets = true;
        proxyNoTimeout = true;
      };

      # Overwrite well-known info
      "= /.well-known/matrix/server" = {
        allowCORS = true;
        return = "200 '${LT.constants.matrixWellKnown.server}'";
        extraConfig = ''
          default_type application/json;
        '';
      };
      "= /.well-known/matrix/client" = {
        allowCORS = true;
        return = "200 '${LT.constants.matrixWellKnown.client}'";
        extraConfig = ''
          default_type application/json;
        '';
      };
    };

    sslCertificate = "zerossl-lantian.pub";
    noIndex.enable = true;
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/matrix-synapse/media 755 matrix-synapse matrix-synapse"
    "d /var/lib/matrix-synapse/remote-media 755 matrix-synapse matrix-synapse"
  ];
}
