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
    pname = "nordpass_password_management";
    version = "5.15.28";
    addonId = "${pname}-${version}";
    url = "https://addons.mozilla.org/firefox/downloads/file/4268660/${addonId}.xpi";
    sha256 = "sha256-TztiIxl9WCpmqtx6rqL+NddyjLia+uUzD/0oej/uzWQ=";
    meta = {
      homepage = "https://nordpass.com/";
      description = "Organize online life with NordPass — a secure solution for passwords, passkeys, credit cards, and more.";
      platforms = lib.platforms.all;
    };
  };
}
