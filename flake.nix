{
  description = "NixOS Configuration Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    flake-parts.url = "github:hercules-ci/flake-parts";

    nur.url = "github:nix-community/NUR";

    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";

    vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    vscode-extensions.inputs.nixpkgs.follows = "nixpkgs";

    automous-zones.url = "github:the-computer-club/automous-zones";
    scalcy.url = "github:simcra/scalcy";
    scalcy.inputs.nixpkgs.follows = "nixpkgs-unstable";
    scalcy.inputs.flake-parts.follows = "flake-parts";
  };

  outputs = { nixpkgs, home-manager, flake-parts, nur, ... } @ inputs:
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
      nixosModules = import ./nixos/modules;
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      flake = rec {
        inherit nixosModules;

        nixosConfigurations = nixpkgs.lib.genAttrs hostNames
          (hostName:
            nixpkgs.lib.nixosSystem {
              specialArgs = {
                inherit overlays azLib azFlakeModules;
              };
              modules = nixpkgs.lib.attrValues nixosModules ++ [
                home-manager.nixosModules.home-manager
                nur.nixosModules.nur
                ./nixos/configurations/${hostName}
              ];
            }
          );
      };
      systems = nixpkgs.lib.systems.flakeExposed;
      perSystem = { pkgs, system, ... }: {
        packages = import ./pkgs { inherit inputs; inherit pkgs; inherit system; };
        formatter = pkgs.nixpkgs-fmt;
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [ nh nixpkgs-fmt ];
        };
      };
    };
}

# Notes for later work
# flake-parts.url = "github:hercules-ci/flake-parts";
# https://flake.parts/getting-started
# https://github.com/the-computer-club/lynx/blob/main/templates/minimal/flake.nix
# https://github.com/the-computer-club/lynx/blob/main/flake-modules/profile-parts-homext.nix
