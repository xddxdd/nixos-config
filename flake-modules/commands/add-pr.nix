_: ''
  wget https://github.com/NixOS/nixpkgs/pull/$1.diff -O patches/nixpkgs/$1.patch
  git add patches/nixpkgs/$1.patch
''
