{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        native = pkgs.callPackage ./default.nix {};
        aarch64 = pkgs.pkgsCross.aarch64-multiplatform.callPackage ./default.nix {};
      in
      {
        defaultPackage = self.packages.${system}.myproject;
        packages = { inherit native aarch64; };
        devShell = with pkgs; mkShell {
          buildInputs = [ cargo podman qemu ];
        };
      }
    );
}
