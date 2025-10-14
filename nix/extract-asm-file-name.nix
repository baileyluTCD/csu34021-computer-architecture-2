{ lib, ... }:
let
  extension = ".asm";
in
{
  options.extractAsmFileName = lib.mkOption {
    description = "nixasm derivation builder";
    default =
      asmFile:
      assert lib.assertMsg (lib.hasSuffix extension asmFile) ''
        `asmFile` must end in `${extension}`
      '';

      let
        stringDropEnd = n: string: string |> lib.stringToCharacters |> lib.dropEnd n |> lib.concatStrings;

        extensionLen = lib.stringLength extension;
      in
      stringDropEnd extensionLen (builtins.baseNameOf asmFile);
  };
}
