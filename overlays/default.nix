{ inputs }:
{
  # Re-export overlays from inputs
  nur = inputs.nur.overlays.default;
  vscode-extensions = inputs.vscode-extensions.overlays.default;
  nixvim = inputs.nixvim.overlays.default;
  scalcy = inputs.scalcy.overlays.default;

  # Add overrides to packages which need to be modified
  nixpkgs-overrides = final: _prev: {
    # System Vencord causes issues with vesktop when using screenshare features
    vesktop = (_prev.vesktop.override { withSystemVencord = false; });

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
