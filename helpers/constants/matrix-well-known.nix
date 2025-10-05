{ portStr, ... }:
{
  server = builtins.toJSON { "m.server" = "matrix.lantian.pub:${portStr.Matrix.Public}"; };
  client = builtins.toJSON {
    "m.server"."base_url" = "https://matrix.lantian.pub";
    "m.homeserver"."base_url" = "https://matrix.lantian.pub";
    "m.identity_server"."base_url" = "https://vector.im";
    "org.matrix.msc3575.proxy"."url" = "https://matrix.lantian.pub";
  };
}
