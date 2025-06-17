{ config, ... }:
{
  imports = [ ../postgresql.nix ];

  services.synapse-auto-compressor = {
    enable = true;
    startAt = "daily";
    settings = {
      chunk_size = 500;
      chunks_to_compress = 100;
    };
  };

  systemd.services.synapse-auto-compressor = {
    # https://github.com/matrix-org/rust-synapse-compress-state/issues/78#issuecomment-1409932869
    path = [ config.services.postgresql.package ];
    preStart = ''
      psql <<_EOF
      BEGIN;

      DELETE
      FROM state_compressor_state AS scs
      WHERE NOT EXISTS
          (SELECT *
           FROM rooms AS r
           WHERE r.room_id = scs.room_id);

      DELETE
      FROM state_compressor_state AS scs
      WHERE scs.room_id in
          (SELECT DISTINCT room_id
           FROM state_compressor_state AS scs2
           WHERE scs2.current_head IS NOT NULL
             AND NOT EXISTS
               (SELECT *
                FROM state_groups AS sg
                WHERE sg.id = scs2.current_head));

      DELETE
      FROM state_compressor_progress AS scp
      WHERE NOT EXISTS
          (SELECT *
           FROM state_compressor_state AS scs
           WHERE scs.room_id = scp.room_id);

      COMMIT;
      _EOF
    '';
  };
}
