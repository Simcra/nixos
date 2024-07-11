{ config, lib, ... }:
let
  inherit (lib)
    mkOption
    mkDefault
    mkIf
    types;
  locales = import ./locales.nix;
  encodings = import ./encodings.nix;
  timezones = import ./timezones.nix;
  kbLayouts = import ./kblayouts.nix;
  kbVariants = import ./kbvariants.nix;
  cfg = config.senix.i18n;
  cfgX11 = config.services.xserver;
in
{
  options.senix.i18n = {
    locale = mkOption {
      type = types.enum locales;
      default = "en_AU";
      description = "The locale to be used by the system";
    };

    encoding = mkOption {
      type = types.enum encodings;
      default = "UTF-8";
      description = "The encoding to be used by the system";
    };

    timezone = mkOption {
      type = types.enum timezones;
      default = "Australia/Adelaide";
      description = "The timezone to be used by the system";
    };

    kbLayout = mkOption {
      type = types.enum kbLayouts;
      default = "au";
      description = "The keyboard layout to be used by the system";
    };

    kbVariant = mkOption {
      type = types.enum kbVariants;
      default = "";
      description = "The keyboard variant to be used by the system";
    };
  };

  config = {
    # Configure defaults
    senix.i18n = {
      locale = mkDefault "en_AU";
      encoding = mkDefault "UTF-8";
      timezone = mkDefault "Australia/Adelaide";
      kbLayout = mkDefault "au";
      kbVariant = mkDefault "";
    };

    # Configure timezone
    time.timeZone = cfg.timezone;

    # Configure i18n
    i18n = rec {
      defaultLocale = "${cfg.locale}.${cfg.encoding}";
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

    # Configure keyboard
    services.xserver.xkb = mkIf cfgX11.enable {
      layout = cfg.kbLayout;
      variant = cfg.kbVariant;
    };
  };
}
