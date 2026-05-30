{
  pkgs,
  ...
}:
{
  services = {
    ollama = {
      enable = true;
      openFirewall = true;
      host = "0.0.0.0";
      port = 11434;
      loadModels = [
        "deepseek-r1:32b"
        "qwen2.5-coder:32b"
      ];
      acceleration = "cuda";
    };
  };

  systemd.services.ollama.serviceConfig = {
    Environment = [
      "OLLAMA_FLASH_ATTENTION=1"
      "CUDA_VISIBLE_DEVICES=0"
    ];
  };

  # Environment
  environment.systemPackages = with pkgs; [
    cudaPackages.cudatoolkit
  ];
}
