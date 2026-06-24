{ LT, ... }:
{
  dialNeverGonna = ''
    [app-never-gonna]
    exten => b,1,Answer()
    same => n,AudioSocket(''${UUID()},127.0.0.1:${LT.portStr.Asterisk.AudioSocket})
    same => n,Hangup()
  '';

  dialNeverGonnaDescription = "Never Gonna Give You Up (Markov chain, <a href=\"https://github.com/xddxdd/never-gonna-rust\" target=\"_blank\">never-gonna-rust</a>)";
}
