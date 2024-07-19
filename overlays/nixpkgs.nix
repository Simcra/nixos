{ inputs }:
{
  # Add unstable nixpkgs 
  unstable = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      inherit (final) system;
      config.allowUnfree = true;
    };
  };

  # Add the NUR and VSCode overlays
  nur = inputs.nur.overlay;
  vscode-extensions = inputs.vscode-extensions.overlays.default;

  # Add custom packages defined in pkgs directory
  packages = final: _prev: import ../pkgs final.pkgs;
}
