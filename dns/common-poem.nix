{ pkgs, dns, ... }:

with dns;
prefix: [
  (PTR { name = "${prefix}2"; target = "one.should.uphold.his.countrys.interest.with.his.life."; })
  (PTR { name = "${prefix}3"; target = "he.should.not.do.things."; })
  (PTR { name = "${prefix}4"; target = "just.to.pursue.his.personal.gains."; })
  (PTR { name = "${prefix}5"; target = "and.he.should.not.evade.responsibilities."; })
  (PTR { name = "${prefix}6"; target = "for.fear.of.personal.loss."; })
]
