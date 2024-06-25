{ inputs, outputs, lib, ... }:
{
  # Configure nixpkgs
  nixpkgs = {
    # Allow proprietary packages to be installed
    config.allowUnfree = lib.mkDefault true;
    # Configure overlays
    overlays = [
      # Add the VSCode and NUR overlays
      inputs.vscode-extensions.overlays.default
      inputs.nur.overlay

      # Add the overlays exported in overlays dir
      outputs.overlays.custom-packages
      outputs.overlays.modified-packages
      outputs.overlays.unstable-packages
    ];
  };

  # Enable home manager and git
  programs.home-manager.enable = lib.mkDefault true;
  programs.git.enable = lib.mkDefault true;

  # Nicely reload systemd units when changing configurations
  systemd.user.startServices = lib.mkDefault "sd-switch";

  # Set the home-manager state version
  home.stateVersion = lib.mkDefault "24.05";
}
