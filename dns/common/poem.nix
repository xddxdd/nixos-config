{
  pkgs,
  config,
  lib,
  LT,
  inputs,
  ...
} @ args: {
  common.poem = prefix: first: let
    idx = n: "${prefix}${builtins.toString (first + n)}";
  in [
    {
      recordType = "PTR";
      name = idx 0;
      target = "one.should.uphold.his.countrys.interest.with.his.life.";
    }
    {
      recordType = "PTR";
      name = idx 1;
      target = "he.should.not.do.things.";
    }
    {
      recordType = "PTR";
      name = idx 2;
      target = "just.to.pursue.his.personal.gains.";
    }
    {
      recordType = "PTR";
      name = idx 3;
      target = "and.he.should.not.evade.responsibilities.";
    }
    {
      recordType = "PTR";
      name = idx 4;
      target = "for.fear.of.personal.loss.";
    }
  ];
}
