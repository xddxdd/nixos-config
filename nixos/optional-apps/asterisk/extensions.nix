{
  pkgs,
  ...
}@args:
let
  # keep-sorted start
  inherit (pkgs.callPackage ./apps/astycrapper.nix args) dialAstyCrapper;
  inherit (pkgs.callPackage ./apps/beverly.nix args) dialBeverly;
  inherit (pkgs.callPackage ./apps/lenny.nix args) dialLenny;
  inherit (pkgs.callPackage ./apps/never-gonna.nix args) dialNeverGonna;
  inherit (pkgs.callPackage ./common.nix args) dialRule;
  inherit (pkgs.callPackage ./enum-verify.nix args) enumVerify;
  inherit (pkgs.callPackage ./local-devices.nix args) destLocal destLocalMessage;
  inherit (pkgs.callPackage ./musics.nix args) destLocalForwardMusic destMusic;
  # keep-sorted end

  voiceRules = ''
    [src-anonymous]
    ; Only allow anonymous inbound call to test numbers
    ${dialRule "04242547XXXX" [ "Goto(dest-local,\${EXTEN:8},1)" ]}
    ${dialRule "+04242547XXXX" [ "Goto(dest-local,\${EXTEN:9},1)" ]}
    ${dialRule "[02-9]XXX" [ "Goto(dest-local,\${EXTEN},1)" ]}

    [src-peers-enum]
    ${enumVerify false "src-peers"}

    [src-peers]
    ; Allow inbound calls
    ${dialRule "04242547XXXX" [ "Goto(dest-local,\${EXTEN:8},1)" ]}
    ${dialRule "+04242547XXXX" [ "Goto(dest-local,\${EXTEN:9},1)" ]}
    ${dialRule "XXXX" [ "Goto(dest-local,\${EXTEN},1)" ]}

    [src-local]
    ${dialRule "733XXXX" [ "Dial(PJSIP/\${EXTEN:3}@sdf)" ]}
    ${dialRule "04242547XXXX" [ "Goto(dest-local,\${EXTEN:8},1)" ]}
    ${dialRule "+04242547XXXX" [ "Goto(dest-local,\${EXTEN:9},1)" ]}
    ${dialRule "042." [
      "Set(CALLERID(num)=+04242547\${CALLERID(num)})"
      "Goto(dest-peers,+\${EXTEN},1)"
    ]}
    ${dialRule "+042." [
      "Set(CALLERID(num)=+04242547\${CALLERID(num)})"
      "Goto(dest-peers,\${EXTEN},1)"
    ]}
    ${dialRule "XXX" [ "Dial(PJSIP/\${EXTEN}@telnyx)" ]}
    ${dialRule "XXXX" [ "Goto(dest-local,\${EXTEN},1)" ]}
    ${dialRule "777XXXXXXX" [ "Dial(PJSIP/1\${EXTEN}@callcentric)" ]}
    ${dialRule "NXXNXXXXXX" [ "Dial(PJSIP/+1\${EXTEN}@telnyx)" ]}
    ${dialRule "." [ "Goto(dest-url,\${EXTEN},1)" ]}

    [src-callcentric]
    ; Remove international call prefix
    ${dialRule "+X!" [ "Goto(src-callcentric,\${EXTEN:1},1)" ]}
    ; All calls go to 0000
    ${dialRule "." [ "Goto(dest-local,0000,1)" ]}

    [src-sdf]
    ; Remove international call prefix
    ${dialRule "+X!" [ "Goto(src-sdf,\${EXTEN:1},1)" ]}
    ; All calls go to 0000
    ${dialRule "." [ "Goto(dest-local,0000,1)" ]}

    [src-telnyx]
    ; Remove international call prefix
    ${dialRule "+X!" [ "Goto(src-telnyx,\${EXTEN:1},1)" ]}
    ; All calls go to ring group
    ${dialRule "." [ "Goto(dest-local,1999,1)" ]}

    [src-zadarma]
    ; Remove international call prefix
    ${dialRule "+X!" [ "Goto(src-zadarma,\${EXTEN:1},1)" ]}
    ; All calls go to 0000
    ${dialRule "." [ "Goto(dest-local,0000,1)" ]}

    [dest-local]
    ${destLocalForwardMusic 4}
    ${dialRule "02XX" [
      "Answer()"
      "ConfBridge(\${EXTEN:2})"
    ]}
    ${destLocal}
    ${dialRule "1900" [
      "Answer()"
      "Milliwatt(m)"
    ]}
    ${dialRule "1901" [
      "Answer()"
      "ReceiveFAX(/var/lib/asterisk/fax/\${STRFTIME(\${EPOCH},,%Y%m%d-%H%M%S)}.tiff, f)"
    ]}
    ${dialRule "1999" [
      "Set(DIALGROUP(mygroup,add)=PJSIP/1000)"
      "Set(DIALGROUP(mygroup,add)=PJSIP/1001)"
      "Set(DIALGROUP(mygroup,add)=PJSIP/1003)"
      "Dial(\${DIALGROUP(mygroup)})"
    ]}
    ${dialRule "2000" [ "Goto(dest-local,\${RAND(2001,2004)},1)" ]}
    ${dialRule "2001" [ "Goto(app-lenny,b,1)" ]}
    ${dialRule "2002" [ "Goto(app-asty-crapper,b,1)" ]}
    ${dialRule "2003" [ "Goto(app-beverly,b,1)" ]}
    ${dialRule "2004" [ "Goto(app-never-gonna,b,1)" ]}
    ${dialRule "." [
      "Answer()"
      "Playback(im-sorry&check-number-dial-again)"
    ]}

    [dest-peers]
    ${dialRule "." [
      "Log(NOTICE, Call From: \${CALLERID(num)})"
      "Set(TARGET_URI=\${ENUMLOOKUP(\${EXTEN},sip,,,tel.dn42)})"
      "Log(NOTICE, Call Outbound URI: \${TARGET_URI})"
      "Dial(PJSIP/dn42-enum-outbound/sip:\${TARGET_URI})"
    ]}

    [dest-music]
    ${destMusic}

    [dest-url]
    ${dialRule "." [
      "Log(NOTICE, Call to anonymous SIP: \${EXTEN}@\${SIPDOMAIN})"
      "Dial(PJSIP/anonymous/sip:\${EXTEN}@\${SIPDOMAIN})"
    ]}
  '';

  messageRules = ''
    [src-anonymous-message]
    ; Only allow anonymous inbound call to test numbers
    ${dialRule "04242547XXXX" [ "Goto(dest-local-message,\${EXTEN:8},1)" ]}
    ${dialRule "+04242547XXXX" [ "Goto(dest-local-message,\${EXTEN:9},1)" ]}
    ${dialRule "[02-9]XXX" [ "Goto(dest-local-message,\${EXTEN},1)" ]}

    [src-local-message]
    ${dialRule "04242547XXXX" [ "Goto(dest-local-message,\${EXTEN:8},1)" ]}
    ${dialRule "+04242547XXXX" [ "Goto(dest-local-message,\${EXTEN:9},1)" ]}
    ${dialRule "042." [
      "Set(USER=\${CUT(CUT(MESSAGE(from),@,1),:,2)})"
      "Set(MESSAGE(from)=<sip:+04242547\${USER}@lantian.dn42>)"
      "Goto(dest-peers-message,+\${EXTEN},1)"
    ]}
    ${dialRule "+042." [
      "Set(USER=\${CUT(CUT(MESSAGE(from),@,1),:,2)})"
      "Set(MESSAGE(from)=<sip:+04242547\${USER}@lantian.dn42>)"
      "Goto(dest-peers-message,\${EXTEN},1)"
    ]}
    ${dialRule "XXXX" [ "Goto(dest-local-message,\${EXTEN},1)" ]}
    ${dialRule "." [ "Goto(dest-url-message,\${EXTEN},1)" ]}

    [src-peers-enum-message]
    ${enumVerify true "src-peers-message-rewrite"}

    [src-peers-message-rewrite]
    ${dialRule "." [
      # Force rewrite MESSAGE(from) so Linphone works correctly
      "Set(USER=\${CUT(CUT(MESSAGE(from),@,1),:,2)})"
      "Set(MESSAGE(from)=<sip:\${USER}@lantian.pub>)"
      "Goto(src-peers-message,\${EXTEN},1)"
    ]}

    [src-peers-message]
    ; Allow inbound calls
    ${dialRule "04242547XXXX" [ "Goto(dest-local-message,\${EXTEN:8},1)" ]}
    ${dialRule "+04242547XXXX" [ "Goto(dest-local-message,\${EXTEN:9},1)" ]}
    ${dialRule "XXXX" [ "Goto(dest-local-message,\${EXTEN},1)" ]}

    [dest-local-message]
    ${destLocalMessage}
    ${dialRule "1902" [
      # Auto reply for testing SMS
      "Set(USER=\${CUT(CUT(MESSAGE(from),@,1),:,2)})"
      "Log(NOTICE, Generating auto reply to \${USER})"
      "Set(MESSAGE(from)=<sip:\${EXTEN}@lantian.pub>)"
      "Set(MESSAGE(to)=<sip:\${USER}@lantian.pub>)"
      "Set(MESSAGE(body)=ACK message from \${USER})"
      "Goto(src-local-message,\${USER},1)"
    ]}

    [dest-peers-message]
    ${dialRule "." [
      "Log(NOTICE, Message From: \${MESSAGE(from)})"
      "Set(TARGET_URI=\${ENUMLOOKUP(\${EXTEN},sip,,,tel.dn42)})"
      "Log(NOTICE, Message Outbound URI: \${TARGET_URI})"
      "Set(MESSAGE(to)=<sip:\${CUT(TARGET_URI,:,1)}>)"
      "Log(NOTICE, Message To: \${MESSAGE(to)})"
      "MessageSend(pjsip:dn42-enum-outbound/sip:\${TARGET_URI})"
    ]}

    [dest-url-message]
    ${dialRule "." [
      "Log(NOTICE, Message to anonymous SIP: \${EXTEN}@\${SIPDOMAIN})"
      "MessageSend(pjsip:anonymous/sip:\${EXTEN}@\${SIPDOMAIN})"
    ]}
  '';
in
{
  extensions = voiceRules + messageRules + dialAstyCrapper + dialBeverly + dialLenny + dialNeverGonna;
}
