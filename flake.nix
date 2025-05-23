{
  description = "Simcra's NixOS configuration flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    home-manager-unstable.url = "github:nix-community/home-manager";
    home-manager-unstable.inputs.nixpkgs.follows = "nixpkgs-unstable";

    flake-compat.url = "github:edolstra/flake-compat";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-utils.url = "github:numtide/flake-utils";

    nur.url = "github:nix-community/NUR";

    vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs = {
        nixpkgs.follows = "nixpkgs-unstable";
        flake-utils.follows = "flake-utils";
      };
    };

    nixvim = {
      url = "github:simcra/nixvim";
      inputs = {
        nixpkgs.follows = "nixpkgs-unstable";
        home-manager.follows = "home-manager-unstable";
        flake-compat.follows = "flake-compat";
        flake-parts.follows = "flake-parts";
        flake-utils.follows = "flake-utils";
      };
    };

    scalcy = {
      url = "github:simcra/scalcy";
      inputs = {
        nixpkgs.follows = "nixpkgs-unstable";
        flake-parts.follows = "flake-parts";
      };
    };

    automous-zones.url = "github:the-computer-club/automous-zones";
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      flake-parts,
      nur,
      automous-zones,
      ...
    }@inputs:
    let
      hostNames = [
        "monadrecon"
        "streambox"
        "voidhawk"
      ];
      overlays = import ./overlays { inherit inputs; };
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      flake = rec {
        nixosModules = import ./nixos/modules;

        nixosConfigurations = nixpkgs.lib.genAttrs hostNames (
          hostName:
          nixpkgs.lib.nixosSystem {
            specialArgs = {
              inherit overlays;
              azLib = automous-zones.lib;
              azFlakeModules = automous-zones.flakeModules;
            };
            modules = nixpkgs.lib.attrValues nixosModules ++ [
              home-manager.nixosModules.home-manager
              nur.modules.nixos.default
              ./nixos/configurations/${hostName}
            ];
          }
        );
      };
      systems = nixpkgs.lib.systems.flakeExposed;
      perSystem =
        { pkgs, ... }:
        {
          formatter = pkgs.nixfmt-rfc-style;
          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              nh
              nixfmt-rfc-style
            ];
          };
        };
    };
}
