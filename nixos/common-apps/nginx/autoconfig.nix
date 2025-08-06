{
  lib,
  ...
}:
let
  domains = [
    "lantian.pub"
    "xuyh0120.win"
    "ltn.pw"
  ];

  emailConfigFor = domain: {
    inherit domain;
    imap = {
      server = "witcher.mxrouting.net";
      port = 993;
      starttls = false;
    };
    smtp = {
      server = "witcher.mxrouting.net";
      port = 465;
      starttls = false;
    };
  };

  minifyXML =
    s:
    lib.concatMapStrings (
      v:
      let
        strip = s: lib.removePrefix " " (lib.removeSuffix " " s);
        process = s: if strip s == s then s else process (strip s);
      in
      process v
    ) (lib.splitString "\n" s);

  autoconfigTemplate =
    cfg:
    minifyXML ''
      <?xml version="1.0" encoding="UTF-8"?>
      <clientConfig version="1.1">
        <emailProvider id="${cfg.domain}">
            <domain>${cfg.domain}</domain>

            <displayName>%EMAILADDRESS%</displayName>
            <displayShortName>%EMAILLOCALPART%</displayShortName>

            <incomingServer type="imap">
            <hostname>${cfg.imap.server}</hostname>
            <port>${builtins.toString cfg.imap.port}</port>
            <socketType>${if cfg.imap.starttls then "STARTTLS" else "SSL"}</socketType>
            <authentication>password-cleartext</authentication>
            <username>%EMAILADDRESS%</username>
          </incomingServer>

            <outgoingServer type="smtp">
            <hostname>${cfg.smtp.server}</hostname>
            <port>${builtins.toString cfg.smtp.port}</port>
            <socketType>${if cfg.smtp.starttls then "STARTTLS" else "SSL"}</socketType>
            <authentication>password-cleartext</authentication>
            <username>%EMAILADDRESS%</username>
            </outgoingServer>
        </emailProvider>
      </clientConfig>
    '';

  autodiscoverTemplate =
    cfg:
    minifyXML ''
      <?xml version="1.0" encoding="utf-8"?>
      <Autodiscover xmlns="http://schemas.microsoft.com/exchange/autodiscover/responseschema/2006">
        <Response xmlns="http://schemas.microsoft.com/exchange/autodiscover/outlook/responseschema/2006a">
          <User>
            <DisplayName>__EMAIL__</DisplayName>
          </User>

          <Account>
            <AccountType>email</AccountType>
            <Action>settings</Action>

            <Protocol>
              <Type>IMAP</Type>
              <TTL>1</TTL>

              <Server>${cfg.imap.server}</Server>
              <Port>${builtins.toString cfg.imap.port}</Port>

              <LoginName>__EMAIL__</LoginName>

              <DomainRequired>on</DomainRequired>
              <DomainName>${cfg.domain}</DomainName>

              <SPA>off</SPA>
              ${if cfg.imap.starttls then "<TLS>on</TLS>" else "<SSL>on</SSL>"}
              <AuthRequired>on</AuthRequired>
            </Protocol>
          </Account>

          <Account>
            <AccountType>email</AccountType>
            <Action>settings</Action>

            <Protocol>
              <Type>SMTP</Type>
              <TTL>1</TTL>

              <Server>${cfg.smtp.server}</Server>
              <Port>${builtins.toString cfg.smtp.port}</Port>

              <LoginName>__EMAIL__</LoginName>

              <DomainRequired>on</DomainRequired>
              <DomainName>${cfg.domain}</DomainName>

              <SPA>off</SPA>
              ${if cfg.smtp.starttls then "<TLS>on</TLS>" else "<SSL>on</SSL>"}
              <AuthRequired>on</AuthRequired>
            </Protocol>
          </Account>
        </Response>
      </Autodiscover>
    '';

  autodiscoverJsonTemplate =
    cfg:
    builtins.toJSON {
      Protocol = "AutodiscoverV1";
      Url = "https://autoconfig.${cfg.domain}/autodiscover/autodiscover.xml";
    };

  mobileconfigTemplate =
    cfg:
    minifyXML ''
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
        <key>HasRemovalPasscode</key>
        <false/>
        <key>PayloadContent</key>
        <array>
          <dict>
            <key>EmailAccountDescription</key>
            <string>__EMAIL__</string>
            <key>EmailAccountName</key>
            <string>__EMAIL__</string>
            <key>EmailAccountType</key>
            <string>EmailTypeIMAP</string>
            <key>EmailAddress</key>
            <string>__EMAIL__</string>
            <key>IncomingMailServerAuthentication</key>
            <string>EmailAuthPassword</string>
            <key>IncomingMailServerHostName</key>
            <string>${cfg.imap.server}</string>
            <key>IncomingMailServerPortNumber</key>
            <integer>${builtins.toString cfg.imap.port}</integer>
            <key>IncomingMailServerUseSSL</key>
            <true/>
            <key>IncomingMailServerUsername</key>
            <string>__EMAIL__</string>
            <key>OutgoingMailServerAuthentication</key>
            <string>EmailAuthPassword</string>
            <key>OutgoingMailServerHostName</key>
            <string>${cfg.smtp.server}</string>
            <key>OutgoingMailServerPortNumber</key>
            <integer>${builtins.toString cfg.smtp.port}</integer>
            <key>OutgoingMailServerUseSSL</key>
            <true/>
            <key>OutgoingMailServerUsername</key>
            <string>__EMAIL__</string>
            <key>OutgoingPasswordSameAsIncomingPassword</key>
            <true/>
            <key>PayloadDescription</key>
            <string>Configure Email Settings</string>
            <key>PayloadDisplayName</key>
            <string>__EMAIL__</string>
            <key>PayloadIdentifier</key>
            <string>com.l11r.goautoconfig.com.apple.mail.managed.7A981A9E-D5D0-4EF8-87FE-39FD6A506FAC</string>
            <key>PayloadType</key>
            <string>com.apple.mail.managed</string>
            <key>PayloadUUID</key>
            <string>7A981A9E-D5D0-4EF8-87FE-39FD6A506FAC</string>
            <key>PayloadVersion</key>
            <real>1</real>
            <key>SMIMEEnablePerMessageSwitch</key>
            <false/>
            <key>SMIMEEnabled</key>
            <false/>
            <key>disableMailRecentsSyncing</key>
            <false/>
          </dict>
        </array>
        <key>PayloadDescription</key>
        <string>Configure Email Settings</string>
        <key>PayloadDisplayName</key>
        <string>__EMAIL__</string>
        <key>PayloadIdentifier</key>
        <string>com.l11r.goautoconfig</string>
        <key>PayloadOrganization</key>
        <string>${cfg.domain}</string>
        <key>PayloadRemovalDisallowed</key>
        <false/>
        <key>PayloadType</key>
        <string>Configuration</string>
        <key>PayloadUUID</key>
        <string>48C88203-4DB9-49E8-B593-4831903605A0</string>
        <key>PayloadVersion</key>
        <integer>1</integer>
      </dict>
      </plist>
    '';
in
{
  lantian.nginxVhosts = builtins.listToAttrs (
    builtins.map (
      domain:
      lib.nameValuePair "autoconfig.${domain}" {
        locations = {
          "/mail/config-v1.1.xml" = {
            return = "200 '${autoconfigTemplate (emailConfigFor domain)}'";
            extraConfig = ''
              add_header 'Content-Type' 'text/xml; charset=utf-8';
            '';
          };
          "/email.mobileconfig".extraConfig = ''
            add_header 'Content-Type' 'text/xml; charset=utf-8';

            content_by_lua_block {
              function get_email()
                local xml = require "xmlSimple"
                local parser = xml.newParser()
                local email = ngx.var.arg_email
                -- Escape string
                return parser:ToXmlString(email)
              end

              local template = '${mobileconfigTemplate (emailConfigFor domain)}'
              local email = get_email()
              local substituted = string.gsub(template, "__EMAIL__", email)
              ngx.say(substituted)
            }
          '';
          "/autodiscover/autodiscover.json" = {
            return = "200 '${autodiscoverJsonTemplate (emailConfigFor domain)}'";
            extraConfig = ''
              default_type application/json;
            '';
          };
          "/autodiscover/autodiscover.xml".extraConfig = ''
            add_header 'Content-Type' 'text/xml; charset=utf-8';

            content_by_lua_block {
              function get_email()
                ngx.req.read_body()
                local req_body = ngx.req.get_body_data()
                if req_body == nil then return "" end

                local xml = require "xmlSimple"
                local parser = xml.newParser()
                local parsed = parser:ParseXmlText(req_body)
                local email = parsed.Autodiscover.Request.EMailAddress:value()
                -- Escape string
                return parser:ToXmlString(email)
              end

              local template = '${autodiscoverTemplate (emailConfigFor domain)}'
              local email = get_email()
              local substituted = string.gsub(template, "__EMAIL__", email)
              ngx.say(substituted)
            }
          '';
        };
        sslCertificate = "zerossl-${domain}";
        noIndex.enable = true;
      }
    ) domains
  );
}
