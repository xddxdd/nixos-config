{ pkgs, lib, LT, config, utils, inputs, ... }@args:

rec {
  externalTrunk = { name, number, url }: ''
    [${name}]
    type=registration
    outbound_auth=${name}
    server_uri=sip:${url}
    client_uri=sip:${number}@${url}
    retry_interval=60
    expiration=120
    contact_user=${number}
    line=yes
    endpoint=${name}

    [${name}](template-endpoint-common)
    context=src-${name}
    outbound_auth=${name}
    from_user=${number}
    aors=${name}

    [${name}](template-aor)
    contact=sip:${url}

    [${name}]
    type=identify
    endpoint=${name}
    match=${url}
  '';
}
