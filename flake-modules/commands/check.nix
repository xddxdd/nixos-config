{ lib, statix, ... }:
''
  ${lib.getExe statix} check . -i _sources
''
