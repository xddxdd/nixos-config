deploy:
	nix run github:serokell/deploy-rs -- -s .

verbose:
	nix run github:serokell/deploy-rs -- -s . -- --show-trace

update:
	nix flake update
