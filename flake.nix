{
  description = "Bouke's package repository";

  inputs.nixpkgs.url = "nixpkgs/nixos-24.11";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ self.overlays.default ];
          };
        in
        {
          packages = {
            inherit (pkgs) nix-remote-shell nix-remote-build;
          };
        }
      ) // {
      overlays.default = final: prev: {
        nix-remote-build = final.callPackage ./nix-remote-build { };
        nix-remote-shell = final.callPackage ./nix-remote-shell { };
      };
    };
}
