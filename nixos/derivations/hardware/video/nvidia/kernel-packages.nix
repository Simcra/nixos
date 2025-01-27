{ config, ... }:
let
  inherit (config.boot.kernelPackages) nvidiaPackages;
in
{
  inherit (nvidiaPackages) stable production latest beta vulkan_beta dc;
  recommended = nvidiaPackages.mkDriver {
    version = "550.144.03";
    sha256_64bit = "sha256-akg44s2ybkwOBzZ6wNO895nVa1KG9o+iAb49PduIqsQ=";
    openSha256 = "sha256-ygH9/UOWs G53eqMbfUcyLAzAN39LJNo+uT4Wue0/7g=";
    settingsSha256 = "sha256-ZopBInC4qaPvTFJFUdlUw4nmn5eRJ1Ti3kgblprEGy4=";
    persistencedSha256 = "sha256-pwbVQ0De8Q4L4XqV11uQIsLUUPFjL9+sABRgGGyr+wc=";
  };
}
