{ lib
, stdenv
, rustPlatform
, fetchFromGitHub
, makeWrapper
, pkg-config
, openssl
, libxkbcommon
, fontconfig
, wayland
, xorg ? null
, ...
}:
rustPlatform.buildRustPackage rec {
  pname = "scalcy";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "simcra";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-u5RRldPOxMmda3s0ZCbSItgtngT/wsstfyh/TuutIsI=";
  };

  cargoHash = "sha256-1bmAgyr/jGM4cr3r5VyrRa4kuoTq6P0qvzhuNwLgG+4=";

  nativeBuildInputs = [
    pkg-config
    openssl
    makeWrapper
  ];

  buildInputs = lib.optionals stdenv.isLinux [
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

  postInstall = lib.optionalString stdenv.isLinux ''
    wrapProgram $out/bin/${pname} --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}"
  '';

  meta = {
    description = "A simple calculator built using Slint UI with the Rust programming language";
    mainProgram = pname;
    homepage = "https://github.com/Simcra/${pname}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
