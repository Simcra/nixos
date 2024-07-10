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
      inputs.flake-utils.follows = "flake-utils";
    };

    automous-zones.url = "github:the-computer-club/automous-zones";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , home-manager
    , ...
    } @ inputs:
    let
      inherit (self) outputs;
      supportedSystems = [
        "aarch64-darwin"
        "aarch64-linux"
        "armv6l-linux"
        "armv7l-linux"
        "i686-linux"
        "riscv64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
      defaults = import ./defaults;
      hosts = import ./hosts;
      hostnames = nixpkgs.lib.attrNames hosts;
      modules = import ./modules;
      overlays = import ./overlays { inherit inputs; };
      users = import ./users;
      specialArgs = { inherit inputs outputs defaults modules overlays users; };
    in
    flake-utils.lib.eachSystem supportedSystems
      (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in
      {
        packages = import ./pkgs pkgs;
        formatter = pkgs.nixpkgs-fmt;
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [ fh nh nixpkgs-fmt ];
        };
      }) // {
      nixosConfigurations = nixpkgs.lib.genAttrs hostnames (hostname:
        nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          modules = [ hosts.${hostname}.configuration ];
        }
      );

      nixosModules = import ./nixos-modules;

      homeConfigurations = nixpkgs.lib.mergeAttrsList (nixpkgs.lib.map
        (hostname:
          let
            homes = hosts.${hostname}.homes;
            usernames = nixpkgs.lib.attrNames homes;
          in
          nixpkgs.lib.mergeAttrsList (nixpkgs.lib.map
            (username:
              nixpkgs.lib.genAttrs [ "${username}@${hostname}" ] (homeConfigurationName:
                home-manager.lib.homeManagerConfiguration {
                  pkgs = self.nixosConfigurations.${hostname}.pkgs;
                  extraSpecialArgs = specialArgs;
                  modules = [ homes.${username} ];
                }
              )
            )
            usernames
          )
        )
        hostnames);
    };
}
