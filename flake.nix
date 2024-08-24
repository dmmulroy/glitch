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
            {
        devShells = {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [gleam erlang_27 rebar3 bun];
          };
        };
      };
      flake = {};
    };
}
