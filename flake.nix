{
  description = "Simcra's NixOS configuration flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-unstable = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    flake-compat.url = "github:edolstra/flake-compat";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-utils.url = "github:numtide/flake-utils";

    nur.url = "github:nix-community/NUR";

    vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      flake-parts,
      nur,
      ...
    }@inputs:
    let
      hostNames = [
        "monadrecon"
        "steelcore"
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
