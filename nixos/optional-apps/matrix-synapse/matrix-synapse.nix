{
  pkgs,
  lib,
  LT,
  config,
  inputs,
  ...
}@args:
{
  imports = [ ../postgresql.nix ];

  age.secrets.glauth-bindpw = {
    file = inputs.secrets + "/glauth-bindpw.age";
    mode = "0444";
  };

  services.matrix-synapse = {
    enable = true;

    plugins = with config.services.matrix-synapse.package.plugins; [
      matrix-http-rendezvous-synapse
      matrix-synapse-ldap3
    ];

    settings = {
      max_upload_size = "500M";
      public_baseurl = "https://matrix.lantian.pub";
      server_name = config.networking.domain;
      url_preview_enabled = true;
      media_store_path = "${config.services.matrix-synapse.dataDir}/media";
      account_threepid_delegates = {
        msisdn = "https://vector.im";
      };
      database = {
        args.user = "matrix-synapse";
        args.database = "matrix-synapse";
        name = "psycopg2";
      };
      listeners = [
        {
          port = 0;
          bind_addresses = [ "/run/matrix-synapse/federation.sock" ];
          type = "http";
          tls = false;
          x_forwarded = true;
          resources = [
            {
              names = [ "federation" ];
              compress = false;
            }
          ];
        }
        {
          port = 0;
          bind_addresses = [ "/run/matrix-synapse/client.sock" ];
          type = "http";
          tls = false;
          x_forwarded = true;
          resources = [
            {
              names = [ "client" ];
              compress = false;
            }
          ];
        }
      ];

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

  systemd.services.matrix-synapse = {
    environment = {
      LD_PRELOAD = "${pkgs.mimalloc}/lib/libmimalloc.so";
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

    sslCertificate = "lantian.pub_ecc";
    noIndex.enable = true;
  };

  lantian.nginxVhosts."matrix-client.lantian.pub" = {
    serverAliases = [ "matrix.lantian.pub" ];
    locations = {
      "/" = {
        proxyPass = "http://unix:/run/matrix-synapse/client.sock";
      };

      # Sliding sync proxy
      "~ ^/(client/|_matrix/client/unstable/org.matrix.msc3575/sync)" = {
        proxyPass = "http://unix:/run/matrix-sliding-sync/listen.socket";
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

    sslCertificate = "lantian.pub_ecc";
    noIndex.enable = true;
  };

  systemd.tmpfiles.rules = [ "d /var/lib/matrix-synapse/media 755 matrix-synapse matrix-synapse" ];
}
