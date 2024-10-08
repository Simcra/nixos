{ config, lib, pkgs, azLib, azFlakeModules, ... }:
let
  hostname = "voidhawk";
  usernames = [ "simcra" ];
in
{
  imports = [ ../. ];

  # Boot configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.availableKernelModules = [ "vmd" "xhci_pci" "megaraid_sas" "ahci" "thunderbolt" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.kernelModules = [ "kvm-intel" ];

  # Platform
  nixpkgs.hostPlatform = "x86_64-linux";
  networking.hostName = hostname;
  hardware.cpu.intel.updateMicrocode = config.hardware.enableRedistributableFirmware;

  # Filesystem
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/a213722d-c87e-43a9-8b6b-9b5e2883c1bf";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/06B3-AC51";
    fsType = "vfat";
    options = [ "fmask=0022" "dmask=0022" ];
  };
  swapDevices = [ ];

  # Locale
  time.timeZone = "Australia/Adelaide";
  i18n = rec {
    defaultLocale = "en_AU.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = defaultLocale;
      LC_IDENTIFICATION = defaultLocale;
      LC_MEASUREMENT = defaultLocale;
      LC_MONETARY = defaultLocale;
      LC_NAME = defaultLocale;
      LC_NUMERIC = defaultLocale;
      LC_PAPER = defaultLocale;
      LC_TELEPHONE = defaultLocale;
      LC_TIME = defaultLocale;
    };
  };
  services.xserver.xkb = {
    layout = "au";
    variant = "";
  };

  # Users
  users.users = lib.genAttrs usernames (username: import ./users/${username}.nix);

  # Home Manager
  home-manager.users = lib.genAttrs usernames (username: import ../../../home-manager/configurations/${hostname}/${username}.nix);

  # Graphics
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement = {
      enable = false;
      finegrained = false;
    };
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
      version = "550.120";
      sha256_64bit = "sha256-gBkoJ0dTzM52JwmOoHjMNwcN2uBN46oIRZHAX8cDVpc=";
      sha256_aarch64 = "sha256-dzTEUuSIWKEuAMhsL9QkR7CCHpm6m9ZwtGSpSKqwJdc=";
      openSha256 = "sha256-O3OrGGDR+xrpfyPVQ04aM3eGI6aWuZfRzmaPjMfnGIg=";
      settingsSha256 = "sha256-fPfIPwpIijoUpNlAUt9C8EeXR5In633qnlelL+btGbU=";
      persistencedSha256 = "sha256-ztEemWt0VR+cQbxDmMnAbEVfThdvASHni4SJ0dTZ2T4=";
    };
  };
  environment.variables.VDPAU_DRIVER = "nvidia";
  environment.sessionVariables.LIBVA_DRIVER_NAME = "nvidia";

  # Firewall
  networking.firewall = {
    # Spotify local discovery
    allowedTCPPorts = [ 57621 ];
    allowedUDPPorts = [ 5353 ];
  } // {
    allowedTCPPorts = [ 27040 ]; # Steam local network transfer
    allowedUDPPortRanges = [{ from = 27031; to = 27036; }]; # Steam client discovery
  } // {
    # Satisfactory
    allowedTCPPorts = [ 5222 6666 ];
    allowedUDPPorts = [ 5222 6666 ];
    allowedUDPPortRanges = [{ from = 7777; to = 7827; }];
  };

  # Wireguard
  networking.wireguard.interfaces = {
    asluni = {
      privateKeyFile = "/var/lib/wireguard/asluni";
      generatePrivateKeyFile = true;
      peers = azLib.toNonFlakeParts azFlakeModules.asluni.wireguard.networks.asluni.peers.by-name;
      ips = [ "172.16.2.12/32" ];
    };
  };
  networking.hosts =
    let
      cypress = [
        "cypress.local"
        "sesh.cypress.local"
        "tape.cypress.local"
        "codex.cypress.local"
        "chat.cypress.local"
      ];
    in
    {
      "172.16.2.1" = cypress;
    };

  # Steam
  programs.steam = {
    enable = true;
    package = pkgs.steam;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = false;
    gamescopeSession.enable = true;
  };
  programs.gamemode = {
    enable = true;
    enableRenice = true;
  };

  # Environment
  environment.systemPackages = with pkgs; [
    mangohud # FPS counter and performance overlay
    megacli # Voidhawk has a MegaRAID SAS card
    ntfs3g # Voidhawk has ntfs volumes connected
    quickemu # Wrapper for QEMU that provides quick VMs

    # All of this is for WINE
    cabextract
    p7zip
    wineWowPackages.stagingFull
    winetricks
  ];
}
