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
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "simcra";
    repo = "scalcy";
    rev = "refs/tags/${version}";
    hash = "sha256-I6p0Cjj52waOCR1wUIlHUmXsCd9f/CKL2To/sakDyYI=";
  };

  cargoHash = "sha256-McFd7NpBTAf+l0eBvohsdxM1MTEq9/T03VirSxS7cb8=";

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
    wrapProgram $out/bin/scalcy --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}"
  '';

  meta = {
    description = "A simple calculator built using Slint UI with the Rust programming language";
    mainProgram = "scalcy";
    homepage = "https://github.com/simcra/scalcy";
    changelog = "https://github.com/simcra/scalcy/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
