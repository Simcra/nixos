{ inputs, lib, overlays, ... }:
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
      overlays.custom-packages
      overlays.modified-packages
      overlays.unstable-packages
    ];
  };
}
