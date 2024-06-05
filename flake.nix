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
    system.stateVersion = "24.05";
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    nixpkgs.config.allowUnfree = true;

    nixosConfigurations.voidhawk = nixpkgs.lib.nixosSystem {
      specialArgs = inputs;
      modules = [ ./voidhawk.nix ];
    };
  };
}
