{
  description = "NixOS Configuration Flake";

  inputs = {
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    nur.url = "github:nix-community/NUR";

    automous-zones.url = "github:the-computer-club/automous-zones";
  };

  outputs = inputs @ { nixpkgs, ... }: {
    nixosConfigurations.voidhawk = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        ./host.nix
        ./hosts/voidhawk.nix
        ./networks/wireguard-asluni.nix
        ./users/simcra.nix
        ./i18n/en_AU-ADL.nix
      ];
    };
  };
}
