{
  self,
  lib,
  config,
  ...
}:
let
  outerConfig = config;
in
{
  perSystem =
    { config, ... }:
    {
      packages =
        builtins.readDir ../assignment_1
        |> lib.attrsToList
        |> builtins.filter ({ value, ... }: value == "regular")
        |> builtins.map (
          { name, ... }:
          let
            filename = outerConfig.extractAsmFileName name;
          in
          {
            ${filename} = config.mkNixAsmDerivation {
              src = self + "/assignment_1/";
              asmFile = builtins.baseNameOf name;
            };
          }
        )
        |> lib.mergeAttrsList;
    };
}
