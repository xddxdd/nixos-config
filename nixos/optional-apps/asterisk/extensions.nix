{
  pkgs,
  ...
}@args:
let
  # keep-sorted start
  inherit (pkgs.callPackage ./apps/astycrapper.nix args) dialAstyCrapper;
  inherit (pkgs.callPackage ./apps/beverly.nix args) dialBeverly;
  inherit (pkgs.callPackage ./apps/lenny.nix args) dialLenny;
  inherit (pkgs.callPackage ./common.nix args) dialRule;
  inherit (pkgs.callPackage ./local-devices.nix args) destLocal destLocalMessage;
  inherit (pkgs.callPackage ./musics.nix args) destLocalForwardMusic destMusic;
  inherit (pkgs.callPackage ./peers.nix args) destPeers destPeersMessage;
  # keep-sorted end

  voiceRules = ''
    [src-anonymous]
    ; Only allow anonymous inbound call to test numbers
    ${dialRule "42402547XXXX" [ "Goto(dest-local,\${EXTEN:8},1)" ]}
    ${dialRule "[02-9]XXX" [ "Goto(dest-local,\${EXTEN},1)" ]}

    [src-peers]
    ; Allow inbound call and peering calls
    ${dialRule "42402547XXXX" [ "Goto(dest-local,\${EXTEN:8},1)" ]}
    ${dialRule "XXXX" [ "Goto(dest-local,\${EXTEN},1)" ]}
    ${dialRule "4240." [ "Goto(dest-peers,\${EXTEN},1)" ]}

    [src-local]
    ${dialRule "733XXXX" [ "Dial(PJSIP/\${EXTEN:3}@sdf)" ]}
    ${dialRule "42402547XXXX" [ "Goto(dest-local,\${EXTEN:8},1)" ]}
    ${dialRule "4240." [ "Goto(dest-peers,\${EXTEN},1)" ]}
    ${dialRule "XXX" [ "Dial(PJSIP/\${EXTEN}@telnyx)" ]}
    ${dialRule "XXXX" [ "Goto(dest-local,\${EXTEN},1)" ]}
    ${dialRule "777XXXXXXX" [ "Dial(PJSIP/1\${EXTEN}@callcentric)" ]}
    ${dialRule "NXXNXXXXXX" [ "Dial(PJSIP/+1\${EXTEN}@telnyx)" ]}
    ${dialRule "X!" [ "Goto(dest-url,\${EXTEN},1)" ]}

    [src-callcentric]
    ; Remove international call prefix
    ${dialRule "+X!" [ "Goto(src-callcentric,\${EXTEN:1},1)" ]}
    ; All calls go to 0000
    ${dialRule "X!" [ "Goto(dest-local,0000,1)" ]}

    [src-sdf]
    ; Remove international call prefix
    ${dialRule "+X!" [ "Goto(src-sdf,\${EXTEN:1},1)" ]}
    ; All calls go to 0000
    ${dialRule "X!" [ "Goto(dest-local,0000,1)" ]}

    [src-telnyx]
    ; Remove international call prefix
    ${dialRule "+X!" [ "Goto(src-telnyx,\${EXTEN:1},1)" ]}
    ; All calls go to ring group
    ${dialRule "X!" [ "Goto(dest-local,1999,1)" ]}

    [src-zadarma]
    ; Remove international call prefix
    ${dialRule "+X!" [ "Goto(src-zadarma,\${EXTEN:1},1)" ]}
    ; All calls go to 0000
    ${dialRule "X!" [ "Goto(dest-local,0000,1)" ]}

    [dest-local]
    ${destLocalForwardMusic 4}
    ${dialRule "0100" [
      "Answer()"
      "Milliwatt(m)"
    ]}
    ${dialRule "0101" [
      "Answer()"
      "ReceiveFAX(/var/lib/asterisk/fax/\${STRFTIME(\${EPOCH},,%Y%m%d-%H%M%S)}.tiff, f)"
    ]}
    ${dialRule "02XX" [
      "Answer()"
      "ConfBridge(\${EXTEN:2})"
    ]}
    ${destLocal}
    ${dialRule "1999" [
      "Set(DIALGROUP(mygroup,add)=PJSIP/1000)"
      "Set(DIALGROUP(mygroup,add)=PJSIP/1001)"
      "Set(DIALGROUP(mygroup,add)=PJSIP/1003)"
      "Dial(\${DIALGROUP(mygroup)})"
    ]}
    ${dialRule "2000" [ "Goto(dest-local,\${RAND(2001,2003)},1)" ]}
    ${dialRule "2001" [ "Goto(app-lenny,b,1)" ]}
    ${dialRule "2002" [ "Goto(app-asty-crapper,b,1)" ]}
    ${dialRule "2003" [ "Goto(app-beverly,b,1)" ]}
    ${dialRule "X!" [
      "Answer()"
      "Playback(im-sorry&check-number-dial-again)"
    ]}

    [dest-peers]
    ${destPeers}

    [dest-music]
    ${destMusic}

    [dest-url]
    ${dialRule "X!" [ "Dial(PJSIP/anonymous/sip:\${EXTEN}@\${SIPDOMAIN})" ]}
  '';

  messageRules = ''
    [src-anonymous-message]
    ; Only allow anonymous inbound call to test numbers
    ${dialRule "42402547XXXX" [ "Goto(dest-local-message,\${EXTEN:8},1)" ]}
    ${dialRule "[02-9]XXX" [ "Goto(dest-local-message,\${EXTEN},1)" ]}

    [src-local-message]
    ${dialRule "42402547XXXX" [ "Goto(dest-local-message,\${EXTEN:8},1)" ]}
    ${dialRule "4240." [ "Goto(dest-peers-message,\${EXTEN},1)" ]}
    ${dialRule "XXXX" [ "Goto(dest-local-message,\${EXTEN},1)" ]}
    ${dialRule "X!" [ "Goto(dest-url-message,\${EXTEN},1)" ]}

    [src-peers-message]
    ; Allow inbound call and peering calls
    ${dialRule "42402547XXXX" [ "Goto(dest-local-message,\${EXTEN:8},1)" ]}
    ${dialRule "XXXX" [ "Goto(dest-local-message,\${EXTEN},1)" ]}
    ${dialRule "4240." [ "Goto(dest-peers-message,\${EXTEN},1)" ]}

    [dest-local-message]
    ${destLocalMessage}

    [dest-peers-message]
    ${destPeersMessage}

    [dest-url-message]
    ${dialRule "X!" [ "MessageSend(pjsip:PJSIP/anonymous/sip:\${EXTEN}@\${SIPDOMAIN})" ]}
  '';
in
{
  extensions = voiceRules + messageRules + dialAstyCrapper + dialBeverly + dialLenny;
}
