{ config, ... }:
let
  inherit (config.boot.kernelPackages) nvidiaPackages;
in
{
  stable = nvidiaPackages.stable;
  recommended = nvidiaPackages.mkDriver {
    version = "550.120";
    sha256_64bit = "sha256-gBkoJ0dTzM52JwmOoHjMNwcN2uBN46oIRZHAX8cDVpc=";
    sha256_aarch64 = "sha256-dzTEUuSIWKEuAMhsL9QkR7CCHpm6m9ZwtGSpSKqwJdc=";
    openSha256 = "sha256-O3OrGGDR+xrpfyPVQ04aM3eGI6aWuZfRzmaPjMfnGIg=";
    settingsSha256 = "sha256-fPfIPwpIijoUpNlAUt9C8EeXR5In633qnlelL+btGbU=";
    persistencedSha256 = "sha256-ztEemWt0VR+cQbxDmMnAbEVfThdvASHni4SJ0dTZ2T4=";
  };
  feature = nvidiaPackages.mkDriver {
    version = "560.35.03";
    sha256_64bit = "sha256-8pMskvrdQ8WyNBvkU/xPc/CtcYXCa7ekP73oGuKfH+M=";
    sha256_aarch64 = "sha256-s8ZAVKvRNXpjxRYqM3E5oss5FdqW+tv1qQC2pDjfG+s=";
    openSha256 = "sha256-/32Zf0dKrofTmPZ3Ratw4vDM7B+OgpC4p7s+RHUjCrg=";
    settingsSha256 = "sha256-kQsvDgnxis9ANFmwIwB7HX5MkIAcpEEAHc8IBOLdXvk=";
    persistencedSha256 = "sha256-E2J2wYYyRu7Kc3MMZz/8ZIemcZg68rkzvqEwFAL3fFs=";
  };
  beta = nvidiaPackages.mkDriver {
    version = "560.31.02";
    sha256_64bit = "sha256-0cwgejoFsefl2M6jdWZC+CKc58CqOXDjSi4saVPNKY0=";
    sha256_aarch64 = "sha256-m7da+/Uc2+BOYj6mGON75h03hKlIWItHORc5+UvXBQc=";
    openSha256 = "sha256-X5UzbIkILvo0QZlsTl9PisosgPj/XRmuuMH+cDohdZQ=";
    settingsSha256 = "sha256-A3SzGAW4vR2uxT1Cv+Pn+Sbm9lLF5a/DGzlnPhxVvmE=";
    persistencedSha256 = "sha256-BDtdpH5f9/PutG3Pv9G4ekqHafPm3xgDYdTcQumyMtg=";
  };
}
