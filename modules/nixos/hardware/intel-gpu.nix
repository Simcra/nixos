{ config, lib, pkgs, ... }: {
  options = {
    hardware.intelgpu = {
      # Which driver is used for the Intel GPU, defaults to i915
      # Xe is only supported on kernel 6.8+
      driver = lib.mkOption {
        description = "Intel GPU driver";
        type = lib.types.enum [ "i915" "xe" ];
        default = "i915";
      };

      # Whether the Intel GPU kernel module should load at initrc, defaults to true
      loadInInitrd = lib.mkEnableOption {
        description = "Should the Intel GPU kernel module be loaded at stage 1 boot?";
        default = true;
      };
    };
  };

  config = {
    # Install the initrd kernel module
    boot.initrd.kernelModules = [ config.hardware.intelgpu.driver ];

    # Set the VDPAU_DRIVER if opengl is enabled
    environment.canTouchEfiVariables = {
      VDPAU_DRIVER = lib.mkIf config.hardware.opengl.enable (lib.mkDefault "va_gl");
    };

    # Add the OpenGL/Graphics driver packages
    hardware.opengl = {
      extraPackages = with pkgs; [
        (if intel-vaapi-driver then intel-vaapi-driver else vaapiIntel)
        intel-media-driver
      ];

      extraPackages32 = with pkgs.driversi686Linux; [
        (if intel-vaapi-driver then intel-vaapi-driver else vaapiIntel)
        intel-media-driver
      ];
    };

    assertions = [
      {
        assertion = (
          config.hardware.intelgpu.driver != "xe"
          || lib.versionAtLeast config.boot.kernelPackages.kernel.version "6.8"
        );
        message = "Intel Xe GPU driver is not supported on kernels earlier than 6.8.";
      }
    ];
  };
}
