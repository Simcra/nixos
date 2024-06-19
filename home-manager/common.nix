{ inputs, outputs, ... }:
{
  # Configure nixpkgs
  nixpkgs = {
    overlays = [
      # Add the VSCode and NUR overlays
      inputs.vscode-extensions.overlays.default
      inputs.nur.overlay

      # Add the overlays exported in overlays dir
      outputs.overlays.custom-packages
      outputs.overlays.modified-packages
      outputs.overlays.unstable-packages
    ];
    # Allow proprietary packages to be installed
    config.allowUnfree = true;
  };

  # Enable home manager and git
  programs.home-manager.enable = true;
  programs.git.enable = true;

  # Nicely reload systemd units when changing configurations
  systemd.user.startServices = "sd-switch";

  # Set the home-manager state version
  home.stateVersion = "24.05";
}
