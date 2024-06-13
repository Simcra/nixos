{ pkgs, lib, ... }:

let
  buildFirefoxXpiAddon =
    { addonId
    , fetchurl ? pkgs.fetchurl
    , meta
    , pname
    , sha256
    , stdenv ? pkgs.stdenv
    , url
    , version
    }:

    stdenv.mkDerivation {
      inherit meta;

      name = "${pname}-${version}";
      src = fetchurl { inherit url sha256; };

      preferLocalBuild = true;
      allowSubstitutes = true;

      buildCommand = ''
        dst="$out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"
        mkdir -p "$dst"
        install -v -m644 "$src" "$dst/${addonId}.xpi"
      '';
    };
in
{
  nordpass-password-management = buildFirefoxXpiAddon rec {
    pname = "nordpass-password-management";
    version = "5.15.28";
    addonId = "nordpassStandalone@nordsecurity.com";
    url = "https://addons.mozilla.org/firefox/downloads/file/4268660/nordpass_password_management-5.15.28.xpi";
    sha256 = "sha256-TztiIxl9WCpmqtx6rqL+NddyjLia+uUzD/0oej/uzWQ=";
    meta = {
      homepage = "https://nordpass.com/";
      description = "NordPass is your freedom from password stress. Generate and securely store strong passwords and autofill them with a single click.";
      mozPermission = [
        "storage"
        "tabs"
        "privacy"
        "contextMenus"
        "idle"
        "alarms"
      ];
      platforms = lib.platforms.all;
    };
  };
}
