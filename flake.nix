{
  description = "NixOS Configuration Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    automous-zones.url = "github:the-computer-club/automous-zones";

    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ { 
    self,
    nixpkgs,
    nixpkgs-unstable,
    automous-zones,
    home-manager,
    ...
  }: {
    nixosConfigurations.voidhawk = nixpkgs.lib.nixosSystem {
      specialArgs = inputs;
      modules = [
        {
          nix.settings.experimental-features = [ "nix-command" "flakes" ];
          nixpkgs.config.allowUnfree = true;
          system.stateVersion = "24.05";
        }
        ./wireguard.nix
        ./voidhawk.nix
      ];
    };
  };
}
