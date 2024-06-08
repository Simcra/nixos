{ inputs, pkgs, ... }: {
  # Modules to be imported for every host
  imports = [ 
    inputs.home-manager.nixosModules.home-manager
    inputs.nur.nixosModules.nur
  ];

  # NixOS version, features and configuration to apply to every host
  system.stateVersion = "24.05";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  # Packages to install on every host
  environment.systemPackages = with pkgs; [ git ];

  # Tell HM to use both global packages and user packages
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
  };
}