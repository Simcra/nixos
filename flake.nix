{
  description = "NixOS Configuration Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    automous-zones.url = "github:the-computer-club/automous-zones";
  };

  outputs = inputs @ { 
    self,
    nixpkgs,
    nixpkgs-unstable,
    automous-zones,
    ...
  }: {
    nixosConfigurations.voidhawk = nixpkgs.lib.nixosSystem {
      system = [ "x86_64-linux" ];
      specialArgs = inputs;
      modules = [
        ./configuration.nix
        ./wireguard.nix
      ];
    };
  };
}
