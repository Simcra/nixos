{ outputs, pkgs, ... }@specialArgs:
{
  imports = [ ./common.nix ];

  home = {
    username = "darkcrystal";
    homeDirectory = "/home/darkcrystal";
  };

  # Configure Firefox
  programs.firefox = {
    enable = true;
    package = pkgs.firefox;
    profiles.default = {
      extensions =
        let
          firefox-addons = pkgs.nur.repos.rycee.firefox-addons;
        in
        [
          firefox-addons.ublock-origin
        ];
    };
  };
}
