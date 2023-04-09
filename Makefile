servers: FORCE
	@nix run .#colmena -- apply --on @server

all: FORCE
	@nix run .#colmena -- apply --on @default

all-boot: FORCE
	@nix run .#colmena -- apply boot --on @default

build: FORCE
	@nix run .#colmena -- build

local: FORCE
	@nix run .#colmena -- apply --on $(shell cat /etc/hostname)

clean: FORCE
	@nix run .#colmena -- exec -- nix-collect-garbage -d

update: FORCE
	@nix flake update
	@nix run .#nvfetcher

update-nur: FORCE
	@nix flake lock --update-input nur-xddxdd

reboot: FORCE
	@ansible-playbook rolling-reboot.yml

FORCE: ;
