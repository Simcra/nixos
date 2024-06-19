{ inputs, ... }:
{
  # Add custom packages defined in pkgs directory
  custom-packages = final: _prev: import ../pkgs final.pkgs;

  # Add overrides to packages which need to be modified
  modified-packages = final: _prev: {
    # System Vencord causes issues with vesktop when using screenshare features
    vesktop = (_prev.vesktop.override {
      withSystemVencord = false;
    });
  };

  # Add unstable nixpkgs 
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.system;
      config.allowUnfree = true;
    };
  };
}
