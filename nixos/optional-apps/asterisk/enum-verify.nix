{
  pkgs,
  lib,
  ...
}:
let
  enumVerify = pkgs.callPackage ../../../pkgs/e164-verify { };
in
{
  enumVerify = goto: ''
    ; https://github.com/YukariChiba/asterisk-config/blob/master/extensions.conf
    exten => _X.,1,NoOp()

    same => n,Set(CALLERID_NUM=''${CALLERID(num)})
    same => n,Set(REAL_SRC=''${CHANNEL(pjsip,remote_addr)})

    same => n,Log(NOTICE, ENUM Verify Started for ''${CALLERID_NUM} and ''${REAL_SRC})
    same => n,AGI(${lib.getExe enumVerify},''${CALLERID_NUM},''${REAL_SRC})

    same => n,Log(NOTICE, ENUM Verify Result: : ''${ENUM_VERIFY_RESULT})
    same => n,GotoIf($["''${ENUM_VERIFY_RESULT}"="PASS"]?trusted)
    same => n,Log(NOTICE, ENUM Error)
    same => n,Hangup(21)

    same => n(trusted),Log(NOTICE, ENUM Verify Success, goto ''${EXTEN})
    same => n,Goto(${goto},''${EXTEN},1)
  '';
}
