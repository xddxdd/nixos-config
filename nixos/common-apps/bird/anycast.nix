{ pkgs, lib, LT, config, utils, inputs, ... }@args:

{
  babel = ''
    protocol babel ltdocker {
      ipv4 {
        import keep filtered;
        import filter {
          if net.len != 32 then reject;
          accept;
        };
        export none;
      };
      ipv6 {
        import keep filtered;
        import filter {
          if net.len != 128 then reject;
          accept;
        };
        export none;
      };
      interface "ns-*" {
        type wired;
        hello interval 1s;
        update interval 1s;
        port 6695;
      };
      interface "ve-*" {
        type wired;
        hello interval 1s;
        update interval 1s;
        port 6695;
      };
    }
  '';
}
