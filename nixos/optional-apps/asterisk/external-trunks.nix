{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: rec {
  externalTrunk = {
    name,
    number,
    url,
    protocol ? "sip",
    extraRegistrationConfig ? "",
    extraEndpointConfig ? "",
  }: ''
    [${name}]
    type=registration
    outbound_auth=${name}
    server_uri=${protocol}:${url}
    client_uri=${protocol}:${number}@${url}
    retry_interval=60
    expiration=120
    contact_user=${number}
    line=yes
    endpoint=${name}
    ${extraRegistrationConfig}

    [${name}](template-endpoint-common)
    context=src-${name}
    outbound_auth=${name}
    from_user=${number}
    aors=${name}
    ${extraEndpointConfig}

    [${name}](template-aor)
    contact=${protocol}:${url}

    [${name}]
    type=identify
    endpoint=${name}
    match=${url}
  '';
}
