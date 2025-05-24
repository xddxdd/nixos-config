_: {
  imports = [ ../postgresql.nix ];

  services.synapse-auto-compressor = {
    enable = true;
    startAt = "daily";
    settings = {
      chunk_size = 500;
      chunks_to_compress = 100;
    };
  };
}
