{ inputs }:
{
  # Re-export overlays from inputs
  nur = inputs.nur.overlay;
  vscode-extensions = inputs.vscode-extensions.overlays.default;

  # Add chaotic-nyx nixpkgs
  nixpkgs-chaotic = final: _prev: {
    chaotic-nyx = import inputs.nixpkgs-unstable {
      inherit (final) system;
      config.allowUnfree = true;
      overlays = [ inputs.chaotic-nyx.overlays.default ];
    };
  };

  # Add custom packages defined in pkgs directory
  nixpkgs-custom = final: _prev: import ./pkgs final.pkgs;

  # Add overrides to packages which need to be modified
  nixpkgs-overrides = final: _prev: {
    # System Vencord causes issues with vesktop when using screenshare features
    vesktop = (_prev.vesktop.override {
      withSystemVencord = false;
    });

    # Enable hybrid codec for Intel VAAPI driver
    intel-vaapi-driver = (_prev.intel-vaapi-driver.override {
      enableHybridCodec = true;
    });
  };

  # Add unstable nixpkgs 
  nixpkgs-unstable = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      inherit (final) system;
      config.allowUnfree = true;
    };
  };
}
