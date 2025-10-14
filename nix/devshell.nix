{ pkgs, flake, ... }:
pkgs.mkShellNoCC {
  packages = with pkgs; [
    nasm
    mold
    flake.packages.${system}.nixasm
  ];
}
