{
  pkgs,
  ...
}:
{
  nixpkgs.config.rocmSupport = true;

  hardware = {
    amdgpu.opencl.enable = true;
    graphics.extraPackages = with pkgs; [
      rocmPackages.clr
      rocmPackages.clr.icd
      rocmPackages.hipblas
      rocmPackages.rocblas
    ];
  };

  services = {
    ollama = {
      enable = true;
      openFirewall = true;
      host = "0.0.0.0";
      port = 11434;
      loadModels = [
        "deepseek-coder-v2:16b"
        "embeddinggemma:300m"
        "qwen2.5-coder:3b"
        "qwen2.5-coder:7b"
        "qwen3:14b"
      ];
      acceleration = "rocm";
      rocmOverrideGfx = "12.0.1";
    };
  };

  systemd.services.ollama.serviceConfig = {
    Environment = [
      "OLLAMA_FLASH_ATTENTION=1"
    ];
  };

  # Environment
  environment = {
    systemPackages = with pkgs; [
      clinfo
      rocmPackages.rocminfo
    ];
  };
}
