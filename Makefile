deploy: FORCE
	nix run github:serokell/deploy-rs -- -s .

verbose: FORCE
	nix run github:serokell/deploy-rs -- -s . -- --show-trace

home: FORCE
	home-manager switch --flake .#lantian

update: FORCE
	nix flake update

update-nur: FORCE
	nix flake lock --update-input nur --update-input nur-xddxdd

FORCE: ;
