{
    rustPlatform,
    dockerTools
}:
let
    myproject = rustPlatform.buildRustPackage {
        pname = "multi-arch-demo";
        version = "1.0.0";
        src = ./.;
        cargoLock = {
            lockFile = ./Cargo.lock;
        };
    };
    docker = dockerTools.buildLayeredImage {
        name = "localhost/myproject";
        config = {
            Cmd = ["${myproject}/bin/multi-arch-demo"];
        };
    };
in { inherit myproject docker; }