{ inputs, outputs, ... }: {
  # Modules to be imported for every host
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.nur.nixosModules.nur
  ];

  # NixOS version, features and configuration to apply to every host
  system.stateVersion = "24.05";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [ 
    outputs.overlays.unstable-packages
    inputs.nur.overlay
  ];

  # Home Manager configuration to apply to every host
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
}