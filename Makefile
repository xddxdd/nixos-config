servers: FORCE
	@nix run .#colmena -- apply --on @server

all: FORCE
	@nix run .#colmena -- apply --on @default

all-boot: FORCE
	@nix run .#colmena -- apply boot --on @default

build: FORCE
	@nom build $(shell nix eval --raw .#buildCommands.all)

build-x86: FORCE
	@nom build $(shell nix eval --raw .#buildCommands.x86_64-linux)

local: FORCE
	@nix run .#colmena -- apply --on $(shell cat /etc/hostname)

clean: FORCE
	@nix run .#colmena -- exec -- nixos-cleanup

update: FORCE
	@nix flake update
	@nix run .#nvfetcher

update-nur: FORCE
	@nix flake lock --update-input nur-xddxdd

push-cache: FORCE
	@attic push lantian $(shell readlink -f .gcroots/*)

reboot: FORCE
	@ansible-playbook rolling-reboot.yml

FORCE: ;
