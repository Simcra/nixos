{ inputs }:
rec {
  # Re-export overlays from inputs
  nur = inputs.nur.overlays.default;
  vscode-extensions = inputs.vscode-extensions.overlays.default;

  # Add overrides to packages which need to be modified
  nixpkgs-overrides = final: _prev: {
    # Enable hybrid codec for Intel VAAPI driver
    intel-vaapi-driver = (_prev.intel-vaapi-driver.override { enableHybridCodec = true; });
    vaapiIntel = (_prev.vaapiIntel.override { enableHybridCodec = true; });
  };

  # Add unstable nixpkgs
  nixpkgs-unstable = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      inherit (final.stdenv.hostPlatform) system;
      config.allowUnfree = true;
      overlays = [
        nur
        vscode-extensions
        nixpkgs-overrides
      ];
    };
  };
}
