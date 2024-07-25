{ config, lib, pkgs, azLib, azFlakeModules, ... }:
let
  hostname = "voidhawk-vm";
  usernames = [ "simcra" ];
in
{
  imports = [ ../. ];

  # Boot configuration
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;
  boot.initrd.availableKernelModules = [ "ata_piix" "ohci_pci" "ehci_pci" "ahci" "sd_mod" "sr_mod" ];

  # Platform
  nixpkgs.hostPlatform = "x86_64-linux";
  networking.hostName = hostname;
  virtualisation.virtualbox.guest.enable = true;

  # Filesystem
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/d3cc35c9-0acd-4436-ba4d-e221f3994eab";
    fsType = "ext4";
  };
  swapDevices = [ ];

  # Users
  users.users = lib.genAttrs usernames (username: import ./users/${username}.nix);

  # Home Manager
  home-manager.users = lib.genAttrs usernames (username: import ../../../home-manager/configurations/${hostname}/${username}.nix);

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
}
