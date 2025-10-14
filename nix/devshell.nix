{
  perSystem =
    { pkgs, self', ... }:
    {
      devShells.default = pkgs.mkShellNoCC {
        packages = with pkgs; [
          nasm
          mold
          self'.packages.nixasm
        ];
      };
    };

}
