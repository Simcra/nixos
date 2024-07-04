{
  description = "NixOS Configuration Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";

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
  };

  outputs = { self, nixpkgs, home-manager, ... } @ inputs:
    let
      inherit (self) outputs;
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "i686-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
      hosts = [
        "streambox"
        "monadrecon"
        "voidhawk"
        "voidhawk-vm"
      ];
    in
    {
      packages = nixpkgs.lib.genAttrs systems (system: import ./pkgs nixpkgs.legacyPackages.${system});
      formatter = nixpkgs.lib.genAttrs systems (system: nixpkgs.legacyPackages.${system}.nixpkgs-fmt);
      devShells = nixpkgs.lib.genAttrs systems (system:
        let pkgs = nixpkgs.legacyPackages.${system}; in {
          default = pkgs.mkShell {
            packages = with pkgs; [
              fh
              nh
              nixpkgs-fmt
            ];
          };
        });

      overlays = import ./overlays { inherit inputs; };

      nixosModules = import ./modules/nixos;
      homeManagerModules = import ./modules/home-manager;
      homeManagerTemplates = import ./home-manager;
      users = import ./users;

      nixosConfigurations = nixpkgs.lib.genAttrs hosts (host:
        nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [ ./hosts/${host} ];
        }
      );

      homeConfigurations = nixpkgs.lib.mergeAttrsList (nixpkgs.lib.map
        (host:
          let
            system = self.nixosConfigurations.${host}.config.nixpkgs.hostPlatform.system;
            hm = import ./hosts/${host}/home-manager;
            usernames = nixpkgs.lib.attrNames hm;
          in
          nixpkgs.lib.mergeAttrsList (nixpkgs.lib.map
            (username:
              nixpkgs.lib.genAttrs [ "${username}@${host}" ] (homeCfgName:
                home-manager.lib.homeManagerConfiguration {
                  pkgs = nixpkgs.legacyPackages.${system};
                  extraSpecialArgs = { inherit inputs outputs; };
                  modules = [ hm.${username} ];
                }
              )
            )
            usernames
          )
        )
        hosts);
    };
}
