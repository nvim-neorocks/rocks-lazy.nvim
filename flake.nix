{
  description = "A rocks.nvim module that helps you manage tree-sitter parsers";

  nixConfig = {
    extra-substituters = "https://neorocks.cachix.org";
    extra-trusted-public-keys = "neorocks.cachix.org-1:WqMESxmVTOJX7qoBC54TwrMMoVI1xAM+7yFin8NRfwk=";
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";

    neorocks.url = "github:nvim-neorocks/neorocks";

    gen-luarc.url = "github:mrcjkb/nix-gen-luarc-json";

    rocks-nvim-flake = {
      url = "github:nvim-neorocks/rocks.nvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lz-n-flake.url = "github:nvim-neorocks/lz.n";

    flake-parts.url = "github:hercules-ci/flake-parts";

    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    neorocks,
    gen-luarc,
    rocks-nvim-flake,
    lz-n-flake,
    flake-parts,
    pre-commit-hooks,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      perSystem = {
        config,
        self',
        inputs',
        system,
        ...
      }: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            rocks-nvim-flake.overlays.default
            self.overlays.default
            neorocks.overlays.default
            gen-luarc.overlays.default
            lz-n-flake.overlays.default
          ];
        };

        luarc = pkgs.mk-luarc {
          nvim = pkgs.neovim-nightly;
          neodev-types = "nightly";
          plugins = with pkgs.lua51Packages; [
            rocks-nvim
            lz-n
          ];
        };

        type-check-nightly = pre-commit-hooks.lib.${system}.run {
          src = self;
          hooks = {
            lua-ls.enable = true;
          };
          settings = {
            lua-ls.config = luarc;
          };
        };

        pre-commit-check = pre-commit-hooks.lib.${system}.run {
          src = self;
          hooks = {
            alejandra.enable = true;
            stylua.enable = true;
            luacheck.enable = true;
            editorconfig-checker.enable = true;
          };
        };

        devShell = pkgs.mkShell {
          name = "rocks-lazy.nvim devShell";
          shellHook = ''
            ${pre-commit-check.shellHook}
            ln -fs ${pkgs.luarc-to-json luarc} .luarc.json
          '';
          buildInputs =
            self.checks.${system}.pre-commit-check.enabledPackages
            ++ (with pkgs; [
              busted-nightly
              lua-language-server
            ]);
        };
      in {
        packages = rec {
          default = neovim-with-rocks;
          neovim-with-rocks = pkgs.neovim-with-rocks;
          # rocks-lazy-nvim = pkgs.lua51Packages.rocks-lazy-nvim;
        };

        devShells = {
          default = devShell;
          inherit devShell;
        };

        checks = {
          inherit
            pre-commit-check
            type-check-nightly
            ;
        };
      };
      flake = {
        overlays.default = import ./nix/overlay.nix {inherit self rocks-nvim-flake;};
      };
    };
}
