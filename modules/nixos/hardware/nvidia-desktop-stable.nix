{ config, ... }:
{
  # Enable the initrd kernel module and load the extra module packages
  boot.extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];
  boot.initrd.kernelModules = [ "nvidia" ];

  # Enable OpenGL with both 32-bit and 64-bit driver support
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  # NVIDIA settings
  hardware.nvidia = {
    # Enable modesettings, required for NVIDIA desktop GPUs
    modesetting.enable = true;

    # Disable power management, this causes a lot of performance issues with NVIDIA desktop GPUs 
    powerManagement = {
      enable = false;
      finegrained = false;
    };

    # Use the proprietary closed-source drivers, because they typically work better
    open = false;

    # Enable the NVIDIA settings application
    nvidiaSettings = true;

    # Use the "stable" branch of the NVIDIA drivers
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Configure Xserver to use the nvidia video drivers
  services.xserver.videoDrivers = [ "nvidia" ];
}
