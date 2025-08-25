{
  description = "Mariadb env";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (
        system:
        import nixpkgs {
          inherit system;
          overlays = [ ];
        }
      );
    in
    {
      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgsFor.${system};
        in
        {
          default =
            let
              homeDir = builtins.getEnv "HOME";
              includePath = [
                "${homeDir}/.moon/include"
                "${pkgs.mariadb-connector-c.dev}/include"
                (builtins.getEnv "C_INCLUDE_PATH")
              ];
              libPath = [
                "${pkgs.mariadb-connector-c.dev}/lib/mariadb"
                (builtins.getEnv "LIBRARY_PATH")
              ];
              ldPath = [
                libPath
                (builtins.getEnv "LD_LIBRARY_PATH")
              ];
            in
            pkgs.mkShell {
              buildInputs = with pkgs; [
                mariadb
                mariadb-connector-c
              ];

              PROJECT_ROOT = builtins.getEnv "PWD";
              C_INCLUDE_PATH = includePath;
              C_LIBRARY_PATH = libPath;
              LD_LIBRARY_PATH = ldPath;
            };
        }
      );
    };
}
