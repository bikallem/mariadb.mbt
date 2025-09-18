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
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            (final: prev: {
              mariadb-scripts = final.callPackage ./nix/mariadb.nix { };
            })
          ];
        };
      in
      {
        devShells.default = pkgs.mkShell {
          shellHook = ''
            export PROJECT_ROOT="$(pwd)";
            export MARIADB_HOME="$PROJECT_ROOT/.mariadb";
            export MARIADB_DATA="$MARIADB_HOME/data";
            export MARIADB_SOCKET="$MARIADB_HOME/mariadb.sock";
            export MARIADB_PID="$MARIADB_HOME/mariadb.pid";
          '';

          buildInputs = with pkgs; [            
            # Database
            mariadb
            mariadb-connector-c
            mariadb-scripts
            mycli # Better MySQL/MariaDB CLI

            # native development tools
            llvmPackages_21.clang-tools # clang-format
            gnumake
            gcc
            gdb            
          ];

          # Environment variables that will be set
          C_INCLUDE_PATH = "${pkgs.mariadb-connector-c.dev}/include";
          LD_LIBRARY_PATH = "${pkgs.mariadb-connector-c}/lib/mariadb";
          MOON_HOME = builtins.getEnv "HOME" + "/.moon";
        };
      }
    );
}
