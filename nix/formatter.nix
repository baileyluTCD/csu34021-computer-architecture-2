{ inputs, lib, ... }:
{
  imports = [
    inputs.treefmt-nix.flakeModule
  ];

  perSystem =
    { pkgs, ... }:
    {
      treefmt = {
        projectRootFile = "flake.nix";

        settings.formatter.nasmfmt = {
          command = lib.getExe pkgs.nasmfmt;
          includes = [ "*.asm" ];
        };

        programs = {
          deadnix.enable = true;
          nixfmt.enable = true;
          mdformat.enable = true;
        };
      };
    };
}
