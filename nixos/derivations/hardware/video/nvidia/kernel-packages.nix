{ config, pkgs, ... }:
let
  inherit (config.boot.kernelPackages) nvidiaPackages;
  drm_fop_flags_linux_612_patch  = pkgs.fetchpatch {
    url = "https://github.com/Binary-Eater/open-gpu-kernel-modules/commit/8ac26d3c66ea88b0f80504bdd1e907658b41609d.patch";
    hash = "sha256-+SfIu3uYNQCf/KXhv4PWvruTVKQSh4bgU1moePhe57U=";
  };
in
{
  stable = nvidiaPackages.stable;
  recommended = nvidiaPackages.mkDriver {
    version = "550.135";
    sha256_64bit = "sha256-ESBH9WRABWkOdiFBpVtCIZXKa5DvQCSke61MnoGHiKk=";
    sha256_aarch64 = "sha256-uyBCVhGZ637wv9JAp6Bq0A4e5aQ84jz/5iBgXdPr2FU=";
    openSha256 = "sha256-426lonLlCk4jahU4waAilYiRUv6bkLMuEpOLkCwcutE=";
    settingsSha256 = "sha256-4B61Q4CxDqz/BwmDx6EOtuXV/MNJbaZX+hj/Szo1z1Q=";
    persistencedSha256 = "sha256-FXKOTLbjhoGbO3q6kRuRbHw2pVUkOYTbTX2hyL/az94=";
  };
  feature = nvidiaPackages.mkDriver {
    version = "565.77";
    sha256_64bit = "sha256-CnqnQsRrzzTXZpgkAtF7PbH9s7wbiTRNcM0SPByzFHw=";
    sha256_aarch64 = "sha256-LSAYUnhfnK3rcuPe1dixOwAujSof19kNOfdRHE7bToE=";
    openSha256 = "sha256-Fxo0t61KQDs71YA8u7arY+503wkAc1foaa51vi2Pl5I=";
    settingsSha256 = "sha256-VUetj3LlOSz/LB+DDfMCN34uA4bNTTpjDrb6C6Iwukk=";
    persistencedSha256 = "sha256-wnDjC099D8d9NJSp9D0CbsL+vfHXyJFYYgU3CwcqKww=";
  };
  beta = nvidiaPackages.mkDriver {
    version = "565.57.01";
    sha256_64bit = "sha256-buvpTlheOF6IBPWnQVLfQUiHv4GcwhvZW3Ks0PsYLHo=";
    sha256_aarch64 = "sha256-aDVc3sNTG4O3y+vKW87mw+i9AqXCY29GVqEIUlsvYfE=";
    openSha256 = "sha256-/tM3n9huz1MTE6KKtTCBglBMBGGL/GOHi5ZSUag4zXA=";
    settingsSha256 = "sha256-H7uEe34LdmUFcMcS6bz7sbpYhg9zPCb/5AmZZFTx1QA=";
    persistencedSha256 = "sha256-hdszsACWNqkCh8G4VBNitDT85gk9gJe1BlQ8LdrYIkg=";
    patchesOpen = [ drm_fop_flags_linux_612_patch ];
  };
}
