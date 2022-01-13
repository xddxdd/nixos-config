deploy: FORCE
	colmena apply --keep-result

verbose: FORCE
	colmena apply --keep-result --show-trace

home: FORCE
	home-manager switch --flake . -b backup

update: FORCE
	nix flake update

update-nur: FORCE
	nix flake lock --update-input nur --update-input nur-xddxdd

FORCE: ;
