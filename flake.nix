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
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    nixosConfigurations.voidhawk = nixpkgs.lib.nixosSystem {
      specialArgs = inputs;
      modules = [ ./voidhawk.nix ];
    };
  };
}
