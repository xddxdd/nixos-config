{ pkgs, dns, ... }:

with dns;
prefix: first: [
  (PTR { name = "${prefix}${builtins.toString (first + 0)}"; target = "one.should.uphold.his.countrys.interest.with.his.life."; })
  (PTR { name = "${prefix}${builtins.toString (first + 1)}"; target = "he.should.not.do.things."; })
  (PTR { name = "${prefix}${builtins.toString (first + 2)}"; target = "just.to.pursue.his.personal.gains."; })
  (PTR { name = "${prefix}${builtins.toString (first + 3)}"; target = "and.he.should.not.evade.responsibilities."; })
  (PTR { name = "${prefix}${builtins.toString (first + 4)}"; target = "for.fear.of.personal.loss."; })
]
