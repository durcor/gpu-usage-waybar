{
  description = "A tool to display GPU usage to Waybar";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = inputs@{ nixpkgs, flake-parts, rust-overlay, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      perSystem = { config, self', pkgs, system, ... }:
        let
          rustToolchain = (pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml).override {
            extensions = [ "rust-src" "rustfmt" "clippy" ];
          };
        in
        {
          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              rustToolchain
              cargo
              rust-analyzer
              # Add any other development tools needed, e.g., git, openssl, etc.
            ];

            # Environment variables for rust-analyzer
            RUST_SRC_PATH = "${rustToolchain}/lib/rustlib/src/rust/library";
          };

          packages.default = pkgs.rustPlatform.buildRustPackage {
            pname = "gpu-usage-waybar"; # Replace with your project's name
            version = (builtins.fromTOML (builtins.readFile ./Cargo.toml)).package.version;
            src = ./.;            # Source code is in the current directory
            cargoLock = {
              lockFile = ./Cargo.lock;
            };
            nativeBuildInputs = with pkgs; [
              pkg-config # Required for some Rust crates that link to C libraries
            ];
            # buildInputs = with pkgs; [
            #   # Add any system-level dependencies required by your Rust project
            #   # e.g., openssl, zlib, etc.
            # ];
          };
        };
    };
}
