{
  config,
  lib,
  pkgs,
  ...
}:
let
  rootDir = ../../..;
  hostname = "steelcore";
  usernames = [
    "darkcrystal"
    "simcra"
  ];
in
{
  imports = [
    ../.
    ../grd.nix
    ../spotify.nix
  ];

  # Platform / Generated
  nixpkgs.hostPlatform = "x86_64-linux";
  networking.hostName = hostname;
  users.users = lib.genAttrs usernames (username: import ./users/${username}.nix);
  home-manager.users = lib.genAttrs usernames (
    username: import (rootDir + "/home-manager/configurations/${hostname}/${username}.nix")
  );

  # Boot configuration
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelModules = [
      "ahci"
      "kvm-intel"
    ];
    kernelPackages = pkgs.linuxPackages_latest;
    initrd.availableKernelModules = [
      "ahci"
      "megaraid_sas"
      "nvme"
      "sd_mod"
      "thunderbolt"
      "usbhid"
      "usb_storage"
      "xhci_pci"
    ];
  };

  # Filesystems
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/f3ebccfa-9f4c-43f1-a7f3-5842bd274d78";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/C19D-F445";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };
    "/media/archive" = {
      device = "/dev/disk/by-uuid/F6E4B290E4B2531B";
      fsType = "ntfs3";
      options = [ "uid=1000" "gid=1000" "umask=077" "nofail" ];
    };
    "/media/storage" = {
      device = "/dev/disk/by-uuid/9CB8A9A2B8A97B80";
      fsType = "ntfs3";
      options = [ "uid=1000" "gid=1000" "umask=007" "nofail" ];
    };
  };
  swapDevices = [ ];

  # Hardware
  hardware = {
    cpu.intel.updateMicrocode = config.hardware.enableRedistributableFirmware;
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  # Programs
  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      gamescopeSession.enable = true;
    };
    gamemode = {
      enable = true;
      enableRenice = true;
    };
  };
  
  # Services
  services = {
    ollama = {
      enable = true;
      package = pkgs.unstable.ollama-vulkan;
      openFirewall = true;
      host = "0.0.0.0";
      port = 11434;
      acceleration = "vulkan";
      loadModels = [ "deepseek-coder-v2:16b" "qwen2.5-coder:7b" "lfm2:24b" ];
    };
    open-webui = {
      enable = true;
      package = pkgs.unstable.open-webui;
      openFirewall = true;
      host = "0.0.0.0";
      port = 3000;
      environment = {
        OLLAMA_BASE_URL = "http://127.0.0.1:11434";
      };
    };
    samba = {
      enable = true;
      package = pkgs.samba4;
      openFirewall = true;
      settings = {
        global = {
          "workgroup" = "WORKGROUP";
          "server string" = "steelcore samba";
          "netbios name" = "steelcore";

          "security" = "user";
          "map to guest" = "bad user";

          "server min protocol" = "SMB2";
          "server max protocol" = "SMB3";
        };

        Archive = {
          "path" = "/media/archive";
          "browseable" = "yes";
          "writable" = "yes";
          "read only" = "no";
          "guest ok" = "no";

          "create mask" = "0700";
          "directory mask" = "0700";

          "valid users" = "simcra";
        };

        Storage = {
          "path" = "/media/storage";
          "browseable" = "yes";
          "writable" = "yes";
          "read only" = "no";
          "guest ok" = "no";

          "create mask" = "0770";
          "directory mask" = "0770";

          "valid users" = "simcra darkcrystal";
        };
      };
    };
    samba-wsdd = {
      enable = true;
      openFirewall = true;
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
      mangohud # FPS counter and performance overlay
      megacli
      ntfs3g
      radeontop
      vesktop
    ];
  };
}
