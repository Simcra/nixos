{ lib, pkgs, ... }:
let
  buildFirefoxXpiAddon = { pname, version, addonId, url, sha256, meta }:
    pkgs.stdenv.mkDerivation {
      inherit meta;

      name = "${pname}-${version}";
      src = pkgs.fetchurl { inherit url sha256; };

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
  nordpass-password-management = buildFirefoxXpiAddon {
    pname = "nordpass-password-management";
    version = "5.23.13";
    addonId = "nordpassStandalone@nordsecurity.com";
    url = "https://addons.mozilla.org/firefox/downloads/file/4367308/nordpass_password_manager-5.23.13.xpi";
    sha256 = "sha256-rM+pY/WICfpxjJvqaoRw5kpWoSclOvTGmfYmh8/kYHg=";
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
