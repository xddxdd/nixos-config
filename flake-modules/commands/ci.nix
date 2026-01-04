{ lib, nix-fast-build, ... }:
''
  ${lib.getExe nix-fast-build} -f .#nixosPackages.$1 --skip-cached --no-nom -j$(nproc)
''
