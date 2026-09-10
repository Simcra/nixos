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
    version = "595.99.02";
    sha256_64bit = "sha256-6HR3lYv3YwcFSTJL1a1slI66btIQ5EAFs+/4SUD24ew=";
    sha256_aarch64 = "sha256-CCqHZTN2KNOZ4yZp2rDcuRJp9pHfRw47k4m4dWnS/2w=";
    openSha256 = "sha256-T36x/jx8yQ8l3LFp1rZIrTfcSwbGy8YSAvXOUSptpb4=";
    settingsSha256 = "sha256-GYCcnxfKPrTCrsmd25sMyzfC5cqJQJx0c31haooyTYM=";
    persistencedSha256 = "sha256-VyKtF/HdHPQrHHK6opSO69M72LmnGZtauuchj9uuje8=";
  };

  feature = nvidiaPackages.mkDriver {
    version = "615.71.09";
    sha256_64bit = "sha256-zc7tIrvrYSSNGm3qvCWWZz46ZQFpjucayNL9wo87cP4=";
    sha256_aarch64 = "sha256-IbekQhE7cFfmnPZaLY9NDYcF7CoNZ+2Qb7sRd4EOgWM=";
    openSha256 = "sha256-3gByMYIwFzRaLdDG+roCEOuKRRJDrljG9AlLnRZTirM=";
    settingsSha256 = "sha256-LK1LU8mDkM/XVRKPBtuOZh9nIP/lGFLAJnmasEX8jhg=";
    persistencedSha256 = "sha256-qPRb+3d88+2RcpUkoBTbjIaImnQ+jX+/6p1vXcJ5geE=";
  };
}

# Helper script to get updated hashes
/**
VERSION="595.99.02"
SHA256_64BIT=$(nix hash convert --hash-algo sha256 --from nix32 --to sri "$(nix-prefetch-url --type sha256 "https://download.nvidia.com/XFree86/Linux-x86_64/${VERSION}/NVIDIA-Linux-x86_64-${VERSION}.run")")
SHA256_AARCH64=$(nix hash convert --hash-algo sha256 --from nix32 --to sri "$(nix-prefetch-url --type sha256 "https://download.nvidia.com/XFree86/Linux-aarch64/${VERSION}/NVIDIA-Linux-aarch64-${VERSION}.run")")
OPEN_SHA256=$(nix hash convert --hash-algo sha256 --from nix32 --to sri "$(nix-prefetch-url --type sha256 --unpack "https://github.com/NVIDIA/open-gpu-kernel-modules/archive/refs/tags/${VERSION}.tar.gz")")
SETTINGS_SHA256=$(nix hash convert --hash-algo sha256 --from nix32 --to sri "$(nix-prefetch-url --type sha256 --unpack "https://github.com/NVIDIA/nvidia-settings/archive/refs/tags/${VERSION}.tar.gz")")
PERSISTENCED_SHA256=$(nix hash convert --hash-algo sha256 --from nix32 --to sri "$(nix-prefetch-url --type sha256 --unpack "https://github.com/NVIDIA/nvidia-persistenced/archive/refs/tags/${VERSION}.tar.gz")")

echo
echo "sha256_64bit = \"${SHA256_64BIT}\";"
echo "sha256_aarch64 = \"${SHA256_AARCH64}\";"
echo "openSha256 = \"${OPEN_SHA256}\";"
echo "settingsSha256 = \"${SETTINGS_SHA256}\";"
echo "persistencedSha256 = \"${PERSISTENCED_SHA256}\";"
*/