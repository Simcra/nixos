{ config, lib, ... }:
let
  inherit (lib)
    mkEnableOption
    mkDefault
    mkIf;
  username = "simcra";
  cfg = config.senix.users.${username};
  cfgHomeManager = config.senix.home-manager;
in
{
  options.senix.users.${username} = {
    enable = mkEnableOption {
      default = false;
      description = "Enables the '${username}' user account";
    };
  };

  # Configure the nixos user
  config = {
    # Configure defaults
    senix.users.${username} = {
      enable = mkDefault false;
    };

    # Configure the NixOS user
    users.users.${username} = mkIf cfg.enable {
      isNormalUser = true;
      description = "Simcra";
      extraGroups = [
        "networkmanager"
        "wheel"
      ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILOvefL7G4P4GUsW+zU6E3h5A2k0fqiE5XB/fICRAVik"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMboS93ic/vd9Fn8Ebpz/IGcK9LahJmCzg+2p7tRXWKI simcra@monadrecon"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICJC93Hq9ShvSpZaEcK7yV8iAS+xoSdoGREEcpU5ldKl simcra@streambox"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEMzU9dSeAoavZcjmhqiWi4nHbh4pcL4eyTeUOMBVUN9 simcra@voidhawk"
      ];
    };

    # Configure Home Manager
    home-manager.users.${username} = mkIf (cfg.enable && cfgHomeManager.enable) (import ./home.nix);
  };
}
