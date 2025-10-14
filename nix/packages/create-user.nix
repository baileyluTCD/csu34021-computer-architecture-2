{ self, ... }:
{
  perSystem =
    { config, ... }:
    {
      packages.createUser = config.mkNixAsmDerivation {
        src = self + "/assignment_1/";
        asmFile = "create_user.asm";
      };
    };
}
