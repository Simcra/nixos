{ config, lib, pkgs, ... } : {
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "24.05";

  # Hardware
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;
  boot.initrd.availableKernelModules = [ "ata_piix" "ohci_pci" "ehci_pci" "ahci" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/d3cc35c9-0acd-4436-ba4d-e221f3994eab";
      fsType = "ext4";
    };

  swapDevices = [ ];
  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  virtualisation.virtualbox.guest.enable = true;

  # Imported modules
  imports = [
    ./i18n-au-adl.nix
    ./users.nix
    ./wireguard.nix
  ];

  # Networking
  networking.hostName = "voidhawk";
  networking.networkmanager.enable = true;
  networking.wireguard.interfaces.asluni.ips = [ "172.16.2.12/32" ];
  networking.hosts = 
    let cypress = [
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

  # X11 / Desktop Environment
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Printing
  services.printing.enable = true;
  
  # Sound
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Programs
  programs.firefox.enable = true;
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  # System Packages
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    (vscode-with-extensions.override {
      vscodeExtensions = with vscode-extensions; [
        ms-azuretools.vscode-docker
        ms-python.python
        ms-vscode.cpptools
        ms-vscode-remote.remote-ssh
        # Nix
        bbenoist.nix
        # Lua
        sumneko.lua
        # Rust
        rust-lang.rust-analyzer
        serayuzgur.crates
        njpwerner.autodocstring
      ];
    })
  ];
}