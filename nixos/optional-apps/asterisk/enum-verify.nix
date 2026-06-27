{
  pkgs,
  lib,
  ...
}:
let
  enumVerify = pkgs.callPackage ../../../pkgs/e164-verify { };
in
{
  enumVerify =
    isMessage: goto:
    let
      callerID = if isMessage then "\${MESSAGE(from)}" else "\${CALLERID(num)}";
      realSource =
        if isMessage then "\${MESSAGE_DATA(PJSIP_RECVADDR)}" else "\${CHANNEL(pjsip,remote_addr)}";
    in
    ''
      ; https://github.com/YukariChiba/asterisk-config/blob/master/extensions.conf
      exten => _.,1,NoOp()

      same => n,Set(CALLERID_NUM=${callerID})
      same => n,Set(REAL_SRC=${realSource})

      same => n,Log(NOTICE, ENUM Verify Started for ''${CALLERID_NUM} and ''${REAL_SRC})
      same => n,AGI(${lib.getExe enumVerify},''${CALLERID_NUM},''${REAL_SRC})

      same => n,Log(NOTICE, ENUM Verify Result: ''${ENUM_VERIFY_RESULT})
      same => n,GotoIf($["''${ENUM_VERIFY_RESULT}"="PASS"]?trusted)
      same => n,Log(NOTICE, ENUM Error)
      same => n,Hangup(21)

      same => n(trusted),Log(NOTICE, ENUM Verify Success, goto ''${EXTEN})
      same => n,Goto(${goto},''${EXTEN},1)
    '';
}
