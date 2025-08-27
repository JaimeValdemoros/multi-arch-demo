{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        myproject-aarch64 = pkgs.pkgsCross.aarch64-multiplatform.rustPlatform.buildRustPackage {
          pname = "multi-arch-demo";
          version = "1.0.0";
          src = ./.;
          cargoLock = {
            lockFile = ./Cargo.lock;
          };
        };
        docker-aarch64 = pkgs.pkgsCross.aarch64-multiplatform.dockerTools.buildLayeredImage {
          name = "localhost/myproject";
          config = {
            Cmd = ["${myproject-aarch64}/bin/multi-arch-demo"];
          };
        };
      in
      {
        defaultPackage = pkgs.pkgsCross.aarch64-multiplatform.stdenv.hostPlatform.emulator { packages = { inherit myproject-aarch64; }; };
        packages = { inherit myproject-aarch64 docker-aarch64; };
        devShell = with pkgs; mkShell {
          buildInputs = [ cargo qemu ];
        };
      }
    );
}
