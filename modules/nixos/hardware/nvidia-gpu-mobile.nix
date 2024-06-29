{ config, lib, pkgs, ... }: {
  imports = [
    ./nvidia-gpu.nix
  ];

  options = {
    # NVIDIA settings
    hardware.nvidia = {
      # Option for enabling NVIDIA Prime offload, recommended for Intel CPUs
      prime.offload.enable = lib.mkEnableOption {
        description = "Use NVIDIA Prime offload, disable NVIDIA Prime sync if you plan to use this";
        default = true;
      };
    };

    # Option for enabling NVIDIA Prime sync, recommended for AMD CPUs
    prime.sync.enable = lib.mkEnableOption {
      description = "Use NVIDIA Prime sync, disable NVIDIA Prime offload if you plan to use this";
      default = true;
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
