{ config, lib, ... }:
{
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
}
