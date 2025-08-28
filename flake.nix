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
        defaultPackage = pkgs.writeShellScriptBin "manifest" ''
          set -euo pipefail
          MANIFEST="$1"
          PUSH_ARGS=( "''${@:2}" )
          # Store images in temp directory instead of polluting user's store
          TMPDIR="$(${pkgs.mktemp}/bin/mktemp -d)"
          HOME=$TMPDIR ${pkgs.podman}/bin/podman manifest create "$MANIFEST" \
            docker-archive:${self.packages.${system}.native.docker} \
            docker-archive:${self.packages.${system}.aarch64.docker}
          echo "Pushing $MANIFEST"
          HOME=$TMPDIR ${pkgs.podman}/bin/podman manifest push "''${PUSH_ARGS[@]}" "$MANIFEST"
          rm -r "$TMPDIR"
        '';
        packages = { inherit native aarch64; };
        devShell = with pkgs; mkShell {
          buildInputs = [ cargo podman qemu ];
        };
      }
    );
}
