{ config, lib, ... }:
{
  options = {
    hardware.nvidia = {
      # Which driver is used for the NVIDIA GPU, defaults to nvidia
      driver = lib.mkOption {
        description = "NVIDIA GPU driver";
        type = lib.types.enum [ "nvidia" "nouveau" ];
        default = "nvidia";
      };
    };
  };

  config = {
    # Add extra module packages
    boot.extraModulePackages =
      if config.hardware.nvidia.driver == "nvidia"
      then with config.boot.kernelPackages; [ nvidia_x11 ]
      else [ ];

    # Install the initrd kernel module
    boot.initrd.kernelModules = [ config.hardware.nvidia.driver ];

    # Enable OpenGL with both 32-bit and 64-bit driver support
    hardware.opengl = {
      enable = lib.mkDefault true;
      driSupport = lib.mkDefault true;
      driSupport32Bit = lib.mkDefault true;
    };

    # NVIDIA settings
    hardware.nvidia = {
      # Enable modesettings, required for most NVIDIA GPUs
      modesetting.enable = lib.mkDefault true;

      # Use the proprietary closed-source drivers, because they typically work better
      open = lib.mkDefault false;

      # Enable the NVIDIA settings application
      nvidiaSettings = lib.mkDefault true;

      # Use the "stable" branch of the NVIDIA drivers
      package = lib.mkDefault config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };
}
