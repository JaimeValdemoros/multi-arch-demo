{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        myproject = pkgs.rustPlatform.buildRustPackage {
          pname = "multi-arch-demo";
          version = "1.0.0";
          src = ./.;
          cargoLock = {
            lockFile = ./Cargo.lock;
          };
        };
      in
      {
        packages = { inherit myproject; };
        devShell = with pkgs; mkShell {
          buildInputs = [ cargo ];
        };
      }
    );
}
