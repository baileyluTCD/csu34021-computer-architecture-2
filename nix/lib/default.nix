{ inputs, ... }:
let
  inherit (inputs.nixpkgs) lib;

  eachSystem = lib.genAttrs (import inputs.systems);
in
eachSystem (
  system:
  let
    pkgs = inputs.nixpkgs.legacyPackages.${system};
  in
  {
    treefmt = inputs.treefmt-nix.lib.evalModule pkgs (import ./treefmtConfig.nix);
  }
)
