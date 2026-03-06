{
  pkgs,
  lib,
  ...
}:
let
  # https://github.com/YukariChiba/asterisk-config/blob/master/agi/enum_verify.py
  enumVerify = pkgs.writeShellApplication {
    name = "enum-verify";
    runtimeInputs = [ (pkgs.python3.withPackages (ps: [ ps.dnspython ])) ];
    text = ''
      python3 ${./enum_verify.py}
    '';
  };
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
