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

            # Database
            mariadb-connector-c
            mycli # Better MySQL/MariaDB CLI

            # Core development tools
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
          C_INCLUDE_PATH = "${pkgs.glibc.dev}/include";
          LIBRARY_PATH = "${pkgs.glibc}/lib";
          NIX_CFLAGS_COMPILE = "-I${pkgs.glibc.dev}/include";
          NIX_LDFLAGS = "-L${pkgs.glibc}/lib";
          MOON_HOME = builtins.getEnv "HOME" + "/.moon";
          DATABASE_URL = "mysql://bikallem:devpass@localhost:3306/moonbit_dev";
          TEST_DATABASE_URL = "mysql://bikallem:devpass@localhost:3306/moonbit_test";
        };
      }
    );
}
