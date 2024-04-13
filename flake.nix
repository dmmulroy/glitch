{
  description = "Description for the project";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs_master.url = "github:NixOS/nixpkgs?ref=master";
  };

  outputs = inputs@{ flake-parts,  ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [];
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      perSystem = { config, self', inputs', pkgs, system, ... }:
      let pkgs' = inputs'.nixpkgs_master.legacyPackages.extend (self: super: {
          gleam = super.stdenv.mkDerivation rec {
          name = "gleam";
          version = "1.1.0-rc3";
          src = super.fetchurl {
          url = "https://github.com/gleam-lang/gleam/releases/download/v${version}/gleam-v${version}-aarch64-apple-darwin.tar.gz";
          sha256 = "sha256-3OEASdaMyOrVR94C96LyWmCn3rW0dVWlgXxBoRyLl3U=";
          };
          phases = [ "installPhase" ];
          installPhase = ''
          mkdir -p $out/bin
          tar -xvf $src -C $out/bin
          chmod +x $out/bin/gleam
          '';
          };
        });
      in
      {
        devShells = {
          default = pkgs'.mkShell {
            buildInputs = with pkgs'; [gleam erlang_26 rebar3 bun];
          };
        };
      };
      flake = {};
    };
}
