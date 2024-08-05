{
  description = "NixOS Configuration Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    chaotic-nyx.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    chaotic-nyx.inputs.nixpkgs.follows = "nixpkgs-unstable";
    chaotic-nyx.inputs.home-manager.follows = "home-manager";

    flake-parts.url = "github:hercules-ci/flake-parts";

    nur.url = "github:nix-community/NUR";

    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";

    vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    vscode-extensions.inputs.nixpkgs.follows = "nixpkgs";

    automous-zones.url = "github:the-computer-club/automous-zones";
  };

  outputs = { nixpkgs, home-manager, chaotic-nyx, nur, flake-parts, ... } @ inputs:
    let
      azLib = inputs.automous-zones.lib;
      azFlakeModules = inputs.automous-zones.flakeModules;
      hostNames = [
        "monadrecon"
        "streambox"
        "voidhawk"
        "voidhawk-vm"
      ];
      overlays = import ./overlays.nix { inherit inputs; };
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      flake = rec {
        nixosConfigurations = nixpkgs.lib.genAttrs hostNames
          (hostName:
            nixpkgs.lib.nixosSystem {
              specialArgs = { inherit overlays azLib azFlakeModules; };
              modules = [
                chaotic-nyx.nixosModules.default
                home-manager.nixosModules.home-manager
                nur.nixosModules.nur
                ./nixos/configurations/${hostName}
              ];
            }
          );
      };
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "armv6l-linux"
        "armv7l-linux"
        "i686-linux"
        "riscv64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
      perSystem = { pkgs, ... }: {
        packages = import ./pkgs pkgs;
        formatter = pkgs.nixpkgs-fmt;
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [ nh nixpkgs-fmt ];
        };
      };
    };
}

# Notes for later work
# flake-parts.url = "github:hercules-ci/flake-parts";~
# https://flake.parts/getting-started
# https://github.com/the-computer-club/lynx/blob/main/templates/minimal/flake.nix
# https://github.com/the-computer-club/lynx/blob/main/flake-modules/profile-parts-homext.nix
