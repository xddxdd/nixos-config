{
  config,
  lib,
  LT,
  ...
}: {
  terraform.backend."pg" = {
    conn_str = "postgres://${LT.hosts."v-ps-fal".ltnet.IPv4}/terraform";
  };

  variable = {
    "email" = {
      description = "Admin Email";
      type = "string";
      sensitive = false;
    };
  };
}
