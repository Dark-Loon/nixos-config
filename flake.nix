{
  description = "Dark Loon's NixOS flake";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixgl.url = "github:nix-community/nixGL";
    niri.url = "github:sodiboo/niri-flake";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      flake-parts,
      nixpkgs,
      nixgl,
      home-manager,
      niri,
      sops-nix,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        ./parts/templates
      ];
      systems = [
        "x86_64-linux"
      ];
      perSystem =
        {
          config,
          pkgs,
          ...
        }:
        {
        };
      flake = {
        nixosConfigurations = {
          nixos = nixpkgs.lib.nixosSystem {
            modules = [
              ./parts/hosts/acer
              {
                nixpkgs.config.allowUnfreePredicate =
                  pkg:
                  builtins.elem (nixpkgs.lib.getName pkg) [
                    "vscode"
                    "vscode-extension-anthropic-claude-code"
                  ];
              }
              niri.nixosModules.niri
              sops-nix.nixosModules.sops
              inputs.home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.armand = ./parts/home;
                home-manager.backupFileExtension = "backup";
              }
            ];
          };
          desktop = nixpkgs.lib.nixosSystem {
            modules = [
              ./parts/hosts/desktop
              {
                nixpkgs.config.allowUnfreePredicate =
                  pkg:
                  builtins.elem (nixpkgs.lib.getName pkg) [
                    "vscode"
                    "claude-code"
                  ];
              }
              niri.nixosModules.niri
              sops-nix.nixosModules.sops
              inputs.home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.armand = ./parts/home;
                home-manager.backupFileExtension = "backup";

              }
            ];
          };
          server = nixpkgs.lib.nixosSystem {
            modules = [
              ./parts/hosts/server
              {
                nixpkgs.config.allowUnfreePredicate =
                  pkg:
                  builtins.elem (nixpkgs.lib.getName pkg) [
                    "vscode"
                    "claude-code"
                  ];
              }
              niri.nixosModules.niri
              sops-nix.nixosModules.sops
              inputs.home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.armand = ./parts/home;
                home-manager.backupFileExtension = "backup";

              }
            ];
          };
        };
      };
    };
}
