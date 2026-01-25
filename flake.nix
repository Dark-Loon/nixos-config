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
    ghostty = {
      url = "github:ghostty-org/ghostty";
    };
  };

  outputs =
    inputs@{
      flake-parts,
      nixpkgs,
      nixgl,
      home-manager,
      ghostty,
      niri,
      sops-nix,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
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
              ./hosts/acer
              (
                { pkgs, ... }:
                {
                  environment.systemPackages = [
                    (pkgs.symlinkJoin {
                      name = "ghostty-wrapped";
                      paths = [
                        (pkgs.writeShellScriptBin "ghostty" ''
                          export LIBGL_ALWAYS_SOFTWARE=1
                          export GALLIUM_DRIVER=llvmpipe
                          exec ${ghostty.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/ghostty "$@"
                        '')
                      ];
                    })

                    pkgs.mesa
                  ];
                }
              )
              {
                nixpkgs.config.allowUnfreePredicate =
                  pkg: builtins.elem (nixpkgs.lib.getName pkg) [ "claude-code" ];
              }
              niri.nixosModules.niri
              sops-nix.nixosModules.sops
              inputs.home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.armand = ./home;
                home-manager.backupFileExtension = "backup";
                home-manager.extraSpecialArgs = { inherit ghostty; };
              }
            ];
          };
          desktop = nixpkgs.lib.nixosSystem {
            modules = [
              ./hosts/acer
              {
                nixpkgs.config.allowUnfreePredicate =
                  pkg: builtins.elem (nixpkgs.lib.getName pkg) [ "claude-code" ];
              }
              niri.nixosModules.niri
              sops-nix.nixosModules.sops
              inputs.home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.armand = ./home;
                home-manager.backupFileExtension = "backup";

              }
            ];
          };
          server = nixpkgs.lib.nixosSystem {
            modules = [
              ./hosts/acer
              {
                nixpkgs.config.allowUnfreePredicate =
                  pkg: builtins.elem (nixpkgs.lib.getName pkg) [ "claude-code" ];
              }
              niri.nixosModules.niri
              sops-nix.nixosModules.sops
              inputs.home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.armand = ./home;
                home-manager.backupFileExtension = "backup";

              }
            ];
          };
        };
      };
    };
}
