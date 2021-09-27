deploy:
	nix run github:serokell/deploy-rs -- .

update:
	nix flake update
