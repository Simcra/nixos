{
  hardware =
    { ... }:
    {
      imports = [
        ./hardware/video/compat.nix
        ./hardware/video/intelgpu.nix
        ./hardware/video/nvidia.nix
      ];
    };
}
