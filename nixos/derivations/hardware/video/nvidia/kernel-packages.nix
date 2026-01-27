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
    version = "580.126.09";
    sha256_64bit = "sha256-TKxT5I+K3/Zh1HyHiO0kBZokjJ/YCYzq/QiKSYmG7CY=";
    sha256_aarch64 = "sha256-c5PEKxEv1vCkmOHSozEnuCG+WLdXDcn41ViaUWiNpK0=";
    openSha256 = "sha256-ychsaurbQ2KNFr/SAprKI2tlvAigoKoFU1H7+SaxSrY=";
    settingsSha256 = "sha256-4SfCWp3swUp+x+4cuIZ7SA5H7/NoizqgPJ6S9fm90fA=";
    persistencedSha256 = "sha256-J1UwS0o/fxz45gIbH9uaKxARW+x4uOU1scvAO4rHU5Y=";
  };
}
