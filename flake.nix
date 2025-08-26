{
  description = "MoonBit development environment with MariaDB";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      ...
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
            nodejs_24

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
            nixd
          ];

          # Environment variables that will be set
          LANG = "en_GB.UTF-8";
          LANGUAGE = "en_GB:en";
          LC_ALL = "en_GB.UTF-8";
          C_INCLUDE_PATH = "${pkgs.mariadb-connector-c.dev}/include";
          LIBRARY_PATH = "${pkgs.mariadb-connector-c}/lib/mariadb";
          NIX_CFLAGS_COMPILE = "-I${pkgs.glibc.dev}/include";
          NIX_LDFLAGS = "-L${pkgs.glibc}/lib";
          MOON_HOME = builtins.getEnv "HOME" + "/.moon";
        };

        formatter = pkgs.nixfmt-tree;
      }
    );
}
