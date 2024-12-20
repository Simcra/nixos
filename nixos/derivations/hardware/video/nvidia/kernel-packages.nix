{ config, ... }:
let
  inherit (config.boot.kernelPackages) nvidiaPackages;
in
{
  inherit (nvidiaPackages) stable production latest beta vulkan_beta dc;
  recommended = nvidiaPackages.mkDriver {
    version = "550.135";
    sha256_64bit = "sha256-ESBH9WRABWkOdiFBpVtCIZXKa5DvQCSke61MnoGHiKk=";
    sha256_aarch64 = "sha256-uyBCVhGZ637wv9JAp6Bq0A4e5aQ84jz/5iBgXdPr2FU=";
    openSha256 = "sha256-426lonLlCk4jahU4waAilYiRUv6bkLMuEpOLkCwcutE=";
    settingsSha256 = "sha256-4B61Q4CxDqz/BwmDx6EOtuXV/MNJbaZX+hj/Szo1z1Q=";
    persistencedSha256 = "sha256-FXKOTLbjhoGbO3q6kRuRbHw2pVUkOYTbTX2hyL/az94=";
  };
}
