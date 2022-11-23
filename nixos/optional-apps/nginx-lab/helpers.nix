{ pkgs, lib, config, utils, inputs, ... }@args:

{
  compressStaticAssets = p: p.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ (with pkgs; [ gzip brotli zstd parallel ]);

    postFixup = (old.postFixup or "") + ''
      OIFS="$IFS"
      IFS=$'\n'

      for FILE in $(find $out/ -type f); do
        echo "gzip -9 -k -f \"$FILE\"" >> parallel.lst
        echo "brotli -9 -k -f \"$FILE\"" >> parallel.lst
        echo "zstd --no-progress -19 -k -f \"$FILE\"" >> parallel.lst
      done

      parallel -j$(nproc) < parallel.lst

      IFS="$OIFS"
    '';
  });
}
