{ inputs }:
{
  # Re-export overlays from inputs
  nur = inputs.nur.overlay;
  vscode-extensions = inputs.vscode-extensions.overlays.default;

  # Add custom packages defined in pkgs directory
  nixpkgs-custom = final: _prev: import ./pkgs { inherit inputs; inherit (final) pkgs system; };

  # Add overrides to packages which need to be modified
  nixpkgs-overrides = final: _prev: {
    # System Vencord causes issues with vesktop when using screenshare features
    vesktop = (_prev.vesktop.override {
      withSystemVencord = false;
    });

    # Enable hybrid codec for Intel VAAPI driver
    intel-vaapi-driver = (_prev.intel-vaapi-driver.override { enableHybridCodec = true; });
    vaapiIntel = (_prev.vaapiIntel.override { enableHybridCodec = true; });
  };

  # Add unstable nixpkgs 
  nixpkgs-unstable = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      inherit (final) system;
      config.allowUnfree = true;
    };
  };
}
