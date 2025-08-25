{
  description = "MoonBit development environment with MariaDB";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Development tools
            git
            nodejs_24
            delta

            # Database
            mariadb-connector-c
            mycli # Better MySQL/MariaDB CLI

            # Core development tools
            llvmPackages_21.clang-tools
            gnumake
            gcc
            gdb
            valgrind

            # nix tools
            nixfmt-rfc-style
            nil
          ];

          # Environment variables that will be set
          LANG = "en_GB.UTF-8";
          LANGUAGE = "en_GB:en";
          LC_ALL = "en_GB.UTF-8";
          C_INCLUDE_PATH = "${pkgs.glibc.dev}/include:${pkgs.mariadb-connector-c.dev}/include";
          LIBRARY_PATH = "${pkgs.glibc}/lib";
          NIX_CFLAGS_COMPILE = "-I${pkgs.glibc.dev}/include";
          NIX_LDFLAGS = "-L${pkgs.glibc}/lib";
          MOON_HOME = builtins.getEnv "HOME" + "/.moon";

          shellHook = ''
            # Configure git to use delta from the Nix environment
            git config --global core.pager "${pkgs.delta}/bin/delta"
            git config --global interactive.diffFilter "${pkgs.delta}/bin/delta --color-only"
            git config --global delta.navigate true
            git config --global delta.light false
            git config --global delta.side-by-side true
          '';
        };
      }
    );
}
