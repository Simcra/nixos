{ config, lib, ... }:
let
  inherit (lib) mkIf;
  username = "darkcrystal";
  cfgHomeManager = config.senix.home-manager;
in
{
  senix.users.${username}.enable = true;
  home-manager.users.${username} = mkIf cfgHomeManager.enable (import ./home.nix);
}
