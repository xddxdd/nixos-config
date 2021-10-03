deploy:
	nix run github:serokell/deploy-rs -- .

verbose:
	nix run github:serokell/deploy-rs -- . -- --show-trace

update:
	nix flake update
