{ config, ... }:
let
  inherit (config.boot.kernelPackages) nvidiaPackages;
in
{
  inherit (nvidiaPackages)
    stable
    production
    latest
    beta
    vulkan_beta
    dc
    ;
  recommended = nvidiaPackages.mkDriver {
    version = "595.91.07";
    sha256_64bit = "sha256-yiPIjdJLB6GRZE4eEc+3vN11NzBXSa9A+YABiwleYxM=";
    sha256_aarch64 = "sha256-fqkN7ONFXtTeXyu2mQxorrk362Epxq3bz88hhKYQzwQ=";
    openSha256 = "sha256-OB8Epd+qn/WywxsPiFpxEOAzlJqb6I1SyRoV3a8l71k=";
    settingsSha256 = "sha256-QzT8Cw1luuZGP9DUje3HN/0ngiayqHURj+bqPsxlJ5w=";
    persistencedSha256 = "sha256-3JQBaNmkwxvCXv9q8aHKas6VZM/JjLsuilC2t7ET0u0=";
  };
}
