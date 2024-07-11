{ inputs, ... }:
{
  # Add the VSCode and NUR overlays
  nixpkgs = {
    vscode-extensions = inputs.vscode-extensions.overlays.default;
    nur = inputs.nur.overlay;

    # Add custom packages defined in pkgs directory
    packages = final: _prev: import ../pkgs final.pkgs;

    # Add overrides to packages which need to be modified
    fixes = final: _prev: {
      # System Vencord causes issues with vesktop when using screenshare features
      vesktop = (_prev.vesktop.override {
        withSystemVencord = false;
      });
    };

    # Add unstable nixpkgs 
    unstable = final: _prev: {
      unstable = import inputs.nixpkgs-unstable {
        inherit (final) system;
        config.allowUnfree = true;
      };
    };
  };
}
