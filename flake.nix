{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        build = pkgs.callPackage ./default.nix {};
      in
      {
        defaultPackage = self.packages.${system}.myproject;
        packages = { inherit (build) myproject docker; };
        devShell = with pkgs; mkShell {
          buildInputs = [ cargo ];
        };
      }
    );
}
