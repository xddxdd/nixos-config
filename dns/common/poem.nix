{ pkgs, lib, dns, ... }:

with dns;
prefix: first: let
  idx = n: "${prefix}${builtins.toString (first + n)}";
in
[
  (PTR { name = idx 0; target = "one.should.uphold.his.countrys.interest.with.his.life."; })
  (PTR { name = idx 1; target = "he.should.not.do.things."; })
  (PTR { name = idx 2; target = "just.to.pursue.his.personal.gains."; })
  (PTR { name = idx 3; target = "and.he.should.not.evade.responsibilities."; })
  (PTR { name = idx 4; target = "for.fear.of.personal.loss."; })
]
