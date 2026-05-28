{
  config,
  lib,
  pkgs,
  ...
}:
let
  rootDir = ../../..;
  hostname = "steelcore";
  users = [
    "darkcrystal"
    "simcra"
  ];
  groups = [ "archive" ];
in
{
  imports = [
    ../.
    ../grd.nix
    ../samba.nix
    ../spotify.nix
  ];

  # Platform / Generated
  nixpkgs.hostPlatform = "x86_64-linux";
  nixpkgs.config.rocmSupport = true;
  networking.hostName = hostname;
  users.users = lib.genAttrs users (user: import ./users/${user}.nix);
  users.groups = lib.genAttrs groups (group: { });
  home-manager.users = lib.genAttrs users (
    user: import (rootDir + "/home-manager/configurations/${hostname}/${user}.nix")
  );
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  # Boot configuration
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelModules = [
      "ahci"
      "amdgpu"
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
      options = [
        "uid=1000"
        "gid=1000"
        "umask=077"
        "nofail"
      ];
    };
    "/media/storage" = {
      device = "/dev/disk/by-uuid/9CB8A9A2B8A97B80";
      fsType = "ntfs3";
      options = [
        "uid=1000"
        "gid=1000"
        "umask=007"
        "nofail"
      ];
    };
  };
  swapDevices = [ ];
  systemd.tmpfiles.rules = [
    "Z /media/archive 2770 simcra archive -"
    "Z /media/storage 2770 simcra users -"
  ];

  # Hardware
  hardware = {
    cpu.intel.updateMicrocode = config.hardware.enableRedistributableFirmware;

    amdgpu.opencl.enable = true;
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        rocmPackages.clr
        rocmPackages.clr.icd
        rocmPackages.hipblas
        rocmPackages.rocblas
      ];
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
      openFirewall = true;
      host = "0.0.0.0";
      port = 11434;
      loadModels = [
        "deepseek-coder-v2:16b"
        "qwen2.5-coder:3b"
        "qwen2.5-coder:7b"
      ];
      acceleration = "rocm";
      rocmOverrideGfx = "12.0.1";
    };

    open-webui = {
      enable = true;
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
          "server string" = "steelcore";
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

          "create mask" = "0770";
          "directory mask" = "0770";

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

    satisfactory-dedicated-server = {
      enable = true;
      openFirewall = true;
      serviceExtraGroups = [ "archive" ];
      backups = {
        enable = true;
        dir = "/media/archive/Backups/STEELCORE";
        period = "daily";
        retention = 14;
      };
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
      clinfo
      mangohud # FPS counter and performance overlay
      megacli
      ntfs3g
      radeontop
      rocmPackages.rocminfo
      vesktop
    ];
  };
}
