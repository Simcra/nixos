{
  lib,
  ...
}:
let
  inherit (lib)
    mkOption
    types
    ;
in
{
  options.desktop.environment = mkOption {
    type = types.enum [
      "gnome"
      "plasma"
    ];
    default = "gnome";
    description = ''
      Desktop environment to use for this NixOS configuration, defaults to "gnome".
    '';
  };

  imports = [
    ./gnome.nix
    ./plasma.nix
  ];
}
