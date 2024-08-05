{ lib, ... }:
let
  inherit (lib)
    mkAliasOptionModule
    optionals
    versionOlder
    version;
in
{
  imports = optionals (versionOlder version "24.11pre") [
    (mkAliasOptionModule [ "hardware" "graphics" "enable" ] [ "hardware" "opengl" "enable" ])
    (mkAliasOptionModule [ "hardware" "graphics" "extraPackages" ] [ "hardware" "opengl" "extraPackages" ])
    (mkAliasOptionModule [ "hardware" "graphics" "extraPackages32" ] [ "hardware" "opengl" "extraPackages32" ])
    (mkAliasOptionModule [ "hardware" "graphics" "enable32Bit" ] [ "hardware" "opengl" "driSupport32Bit" ])
    (mkAliasOptionModule [ "hardware" "graphics" "package" ] [ "hardware" "opengl" "package" ])
    (mkAliasOptionModule [ "hardware" "graphics" "package32" ] [ "hardware" "opengl" "package32" ])
  ];
}
