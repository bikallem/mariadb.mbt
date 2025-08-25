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

          shellHook = ''
            # Set locale to en_GB.UTF-8
            export LANG=en_GB.UTF-8
            export LANGUAGE=en_GB:en
            export LC_ALL=en_GB.UTF-8

            # Ensure Nix paths don't conflict with system libraries
            export NIX_LD_LIBRARY_PATH="$LD_LIBRARY_PATH"
            export LD_LIBRARY_PATH="${pkgs.stdenv.cc.cc.lib}/lib:$LD_LIBRARY_PATH"

            # Check if we're in fish shell
            if test -n "$FISH_VERSION" 2>/dev/null; then
              echo "🐟 Fish shell detected!"
            fi

            echo "🌙 MoonBit Development Environment with MariaDB"
            echo "=============================================="
            echo "Nix packages loaded successfully!"
            echo "User: bikallem"
            echo "Shell: $(basename $SHELL)"
            echo "Locale: $LANG"
            echo "Date: $(date '+%d/%m/%Y %H:%M:%S %Z')"
            echo ""

            # Check MoonBit installation
            if command -v moon >/dev/null 2>&1; then
              echo "MoonBit Version: $(moon version 2>&1 | head -n1)"
            else
              echo "⚠️  MoonBit not found in PATH"
              echo "   Run: curl -fsSL https://cli.moonbitlang.com/install/unix.sh | bash"
            fi

            # Check MariaDB status
            if sudo service mariadb status >/dev/null 2>&1; then
              echo "MariaDB: Running ✅"
            else
              echo "MariaDB: Stopped ⚠️"
              echo "   Run: db-start to start MariaDB"
            fi

            # Check direnv
            if command -v direnv >/dev/null 2>&1; then
              echo "direnv: Available ✅ ($(direnv version))"
            else
              echo "direnv: Not found ⚠️"
            fi

            # Check Starship (from system)
            if command -v starship >/dev/null 2>&1; then
              echo "Starship: Available ✅ ($(starship --version | head -n1))"
            fi
            echo ""

            echo "Environment variables set:"
            echo "  C_INCLUDE_PATH: $C_INCLUDE_PATH"
            echo "  LIBRARY_PATH: $LIBRARY_PATH"
            echo "  PKG_CONFIG_PATH: $PKG_CONFIG_PATH"
            echo ""

            # Set up environment variables for C development
            export C_INCLUDE_PATH="${pkgs.glibc.dev}/include:$C_INCLUDE_PATH"
            export CPLUS_INCLUDE_PATH="$C_INCLUDE_PATH"
            export LIBRARY_PATH="${pkgs.glibc}/lib:$LIBRARY_PATH"
            export PKG_CONFIG_PATH="${pkgs.pkg-config}/lib/pkgconfig:$PKG_CONFIG_PATH"

            # MoonBit environment variables
            export MOON_HOME="$HOME/.moon"
            export PATH="$MOON_HOME/bin:$PATH"

            # Database environment variables
            export DATABASE_URL="mysql://bikallem:devpass@localhost:3306/moonbit_dev"
            export TEST_DATABASE_URL="mysql://bikallem:devpass@localhost:3306/moonbit_test"

            # Create project structure if it doesn't exist
            if [ ! -f "moon.mod.json" ]; then
              echo "💡 Tips:"
              echo "   • Initialise a new MoonBit project: 'moon new <project-name>' or 'moon-init <project-name>'"
              echo "   • Connect to MariaDB: 'db-connect' or 'mycli -u bikallem -pdevpass moonbit_dev'"
              echo "   • View database info: 'db-info'"
            fi
          '';

          # Environment variables that will be set
          LANG = "en_GB.UTF-8";
          LANGUAGE = "en_GB:en";
          LC_ALL = "en_GB.UTF-8";
          C_INCLUDE_PATH = "${pkgs.glibc.dev}/include";
          LIBRARY_PATH = "${pkgs.glibc}/lib";
          NIX_CFLAGS_COMPILE = "-I${pkgs.glibc.dev}/include";
          NIX_LDFLAGS = "-L${pkgs.glibc}/lib";
          MOON_HOME = "$HOME/.moon";
          DATABASE_URL = "mysql://bikallem:devpass@localhost:3306/moonbit_dev";
          TEST_DATABASE_URL = "mysql://bikallem:devpass@localhost:3306/moonbit_test";
        };
      }
    );
}
