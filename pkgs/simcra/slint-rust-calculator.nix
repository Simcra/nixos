{ lib
, fetchFromGitHub
, rustPlatform
, pkg-config
, openssl
, makeWrapper
, libxkbcommon
, fontconfig
, wayland
, xorg
, ...
}:
rustPlatform.buildRustPackage rec {
  pname = "slint-rust-calculator";
  version = "v0.1.0";

  src = fetchFromGitHub {
    owner = "Simcra";
    repo = pname;
    rev = version;
    hash = "sha256-mnfNPef4QddF1IunHBLbXQ19FTAuynd5soI4drLPwNA=";
  };

  meta = {
    description = "A simple calculator built with Slint and Rust";
    homepage = "https://github.com/Simcra/${pname}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };

  cargoHash = "sha256-7rNe7Vq3LsvTwgkY0dFZG41bt5u+4LEIS8h4xgHLYBA=";

  nativeBuildInputs = [
    pkg-config
    openssl
    makeWrapper
  ];

  buildInputs = [
    libxkbcommon
    fontconfig

    # Wayland
    wayland

    # Xorg/X11
    xorg.libX11
    xorg.libXcursor
    xorg.libXrandr
    xorg.libXi
  ];

  LD_LIBRARY_PATH = lib.makeLibraryPath buildInputs;

  postInstall = ''
    wrapProgram $out/bin/${pname} --prefix LD_LIBRARY_PATH: "${lib.makeLibraryPath buildInputs}";
  '';
}
