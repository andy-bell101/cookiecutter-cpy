{
  inputs = {
    nixpkgs.url = "github:cachix/devenv-nixpkgs/rolling";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
    devenv = {
      url = "github:cachix/devenv";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-python = {
      url = "github:cachix/nixpkgs-python";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  nixConfig = {
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };

  outputs = {
    self,
    nixpkgs,
    devenv,
    systems,
    ...
  } @ inputs: let
    forEachSystem = nixpkgs.lib.genAttrs (import systems);
  in {
    packages = forEachSystem (system: {
      devenv-up = self.devShells.${system}.default.config.procfileScript;
    });

    devShells =
      forEachSystem
      (system: let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        pkgs-unstable = import inputs.nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
      in {
        default = devenv.lib.mkShell {
          inherit inputs pkgs;
          modules = [
            (
              {
                pkgs,
                config,
                ...
              }: {
                env = {
                  PYTHONPATH = config.devenv.root;
                };
                packages = with pkgs;
                  [
                    clang-tools
                    cmake
                    ninja
                    sccache
                  ]
                  ++ nixpkgs.lib.optionals pkgs.stdenv.isDarwin (with pkgs.darwin.apple_sdk; [
                    frameworks.CoreServices
                    frameworks.Security
                  ]);

                # https://devenv.sh/reference/options/
                languages.python = {
                  enable = true;
                  uv = {
                    enable = true;
                    package = pkgs-unstable.uv;
                    sync = {
                      enable = true;
                      allExtras = true;
                    };
                  };
                  version = "3.12";
                };
                git-hooks.hooks = {
                  alejandra.enable = true;
                  clang-format.enable = true;
                  cmake-format.enable = true;
                  prettier.enable = true;
                  ruff.enable = true;
                  trim-trailing-whitespace.enable = true;
                };
              }
            )
          ];
        };
      });
  };
}
