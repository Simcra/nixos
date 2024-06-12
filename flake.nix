{
  description = "NixOS Configuration Flake";

  inputs = {
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    nur.url = "github:nix-community/NUR";

    vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    vscode-extensions.inputs.nixpkgs.follows = "nixpkgs";

    automous-zones.url = "github:the-computer-club/automous-zones";
  };

  outputs =
    { self
    , nixpkgs
    , nixpkgs-unstable
    , ...
    } @ inputs:
    let inherit (self) outputs; in {
      overlays = import ./overlays.nix { inherit inputs; };

      nixosConfigurations = {
        voidhawk-vm = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [
            ./host.nix
            ./hosts/voidhawk-vm.nix
            ./network/wireguard-asluni.nix
            ./users/simcra.nix
            ./i18n/en_AU-ADL.nix
          ];
        };
      };
    };
}
