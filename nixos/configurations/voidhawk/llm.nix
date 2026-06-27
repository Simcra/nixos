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
        "gemma4:26b"
        "qwen3-coder:30b"
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
