_: final: prev: {
  waagent = prev.waagent.override { python3 = final.python312; };
}
