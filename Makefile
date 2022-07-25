servers: FORCE
	@nix run .#colmena -- apply --on @server

all: FORCE
	@nix run .#colmena -- apply

build: FORCE
	@nix run .#colmena -- build

local: FORCE
	@nix run .#colmena -- apply --on $(shell cat /etc/hostname)

clean: FORCE
	@nix run .#colmena -- exec -- nix-collect-garbage -d

verbose: FORCE
	@nix run .#colmena -- apply --show-trace

update: FORCE
	@nix flake update
	@nix run .#nvfetcher

update-nur: FORCE
	@nix flake lock --update-input nur-xddxdd

FORCE: ;
