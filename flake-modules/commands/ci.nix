{ nix-fast-build, ... }:
''
  ${nix-fast-build}/bin/nix-fast-build -f .#nixosPackages.$1 --skip-cached --no-nom -j$(nproc)
''
