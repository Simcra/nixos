{ config, lib, pkgs, ... }: {
  imports = [
    ./nvidia-gpu.nix
  ];

  options = {
    # NVIDIA settings
    hardware.nvidia = {
      # Option for enabling NVIDIA Prime offload, recommended for Intel CPUs
      # Disable sync if you enable this one, this is enabled by default
      prime.offload.enable = lib.mkEnableOption
        (lib.mdDoc "Use NVIDIA Prime offload, works better for Intel CPUs.")
        { default = lib.mkOverride 990 true; };

      # Option for enabling NVIDIA Prime sync, recommended for AMD CPUs
      # Disable offload if you enable this one, this is disabled by default
      prime.sync.enable = lib.mkEnableOption
        (lib.mdDoc "Use NVIDIA Prime sync, works better for AMD CPUs.")
        { default = lib.mkOverride 990 false; };
    };
  };

  config = {
    # NVIDIA settings
    hardware.nvidia = {
      # Enable power management for mobile devices
      powerManagement.enable = lib.mkDefault true;

      # Enable offload command if NVIDIA Prime offload is enabled
      prime.enableOffloadCmd = lib.mkIf config.hardware.nvidia.prime.offload.enable true;
    };

    # Add the OpenGL/Graphics driver packages
    hardware.opengl = {
      extraPackages = with pkgs; [ (if libva-vdpau-driver then libva-vdpau-driver else vaapiVdpau) ];
      extraPackages32 = with pkgs.driversi686Linux; [ (if libva-vdpau-driver then libva-vdpau-driver else vaapiVdpau) ];
    };
  };
}
