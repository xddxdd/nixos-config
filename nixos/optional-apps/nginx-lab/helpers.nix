{ config, pkgs, lib, ... }:

{
  compressStaticAssets = attrs: attrs // {
    nativeBuildInputs = (attrs.nativeBuildInputs or [ ]) ++ (with pkgs; [ gzip brotli zstd parallel ]);

    postFixup = (attrs.postFixup or "") + ''
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
  };
}
