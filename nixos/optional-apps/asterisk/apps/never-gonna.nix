_: {
  dialNeverGonna = ''
    [app-never-gonna]
    exten => b,1,Answer()
    same => n,NeverGonna()
    same => n,Hangup()
  '';

  dialNeverGonnaDescription = "Never Gonna Give You Up (Markov chain)";
}
