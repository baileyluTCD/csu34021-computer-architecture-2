{ flake, system, ... }: 
flake.lib.${system}.mkNixAsmDerivation {
  src = flake + "/assignment_1/";
  asmFile = "create_user.asm";
}
