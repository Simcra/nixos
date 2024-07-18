{
  description = "NixOS Configuration Flake";

  inputs = {
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    automous-zones.url = "github:the-computer-club/automous-zones";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";
  };

  outputs =
    { self
    , nixpkgs
    , home-manager
    , nur
    , flake-parts
    , ...
    } @ inputs:
    let
      hosts = import ./hosts;
      modules = import ./modules;
      overlays = import ./overlays { inherit inputs; };
      nixosModules = modules.nixos;
      homeManagerModules = modules.home-manager;
      hostnames = nixpkgs.lib.attrNames hosts;
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      flake = {
        inherit
          overlays
          nixosModules
          homeManagerModules;

        nixosConfigurations = nixpkgs.lib.genAttrs hostnames (hostName:
          nixpkgs.lib.nixosSystem {
            specialArgs = { inherit inputs overlays homeManagerModules; };
            modules = [
              home-manager.nixosModules.home-manager
              nur.nixosModules.nur
              self.nixosModules.senix
              hosts.${hostName}
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
