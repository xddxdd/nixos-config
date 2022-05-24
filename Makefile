all: FORCE
	@nix run .#colmena -- apply

local: FORCE
	@nix run .#colmena -- apply --on $(shell cat /etc/hostname)

clean: FORCE
	@nix run .#colmena -- exec -- nix-collect-garbage -d

verbose: FORCE
	@nix run .#colmena -- apply --show-trace

update: FORCE
	@nix flake update

update-nur: FORCE
	@nix flake lock --update-input nur-xddxdd

FORCE: ;
