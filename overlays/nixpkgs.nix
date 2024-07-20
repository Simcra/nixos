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

  # Add overrides to packages which need to be modified
  fixes = final: _prev: {
    # System Vencord causes issues with vesktop when using screenshare features
    vesktop = (_prev.vesktop.override {
      withSystemVencord = false;
    });

    # Enable hybrid codec for Intel VAAPI driver
    intel-vaapi-driver = (_prev.intel-vaapi-driver.override {
      enableHybridCodec = true;
    });
  };
}
