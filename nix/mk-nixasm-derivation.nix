{
  flake-parts-lib,
  lib,
  config,
  ...
}:
{
  options.perSystem = flake-parts-lib.mkPerSystemOption (
    { pkgs, ... }:
    {
      options.mkNixAsmDerivation = lib.mkOption {
        description = "nixasm derivation builder";
        default = lib.extendMkDerivation {
          constructDrv = pkgs.stdenvNoCC.mkDerivation;

          extendDrvArgs =
            _finalAttrs:
            { asmFile, ... }@args:
            assert lib.assertMsg (builtins.isString asmFile) ''
              `asmFile` must be a string to search for in the root
              of the `src` directory.
            '';

            rec {
              name = config.extractAsmFileName asmFile;

              preBuild =
                args.postUnpack or ''
                  if [ ! -f "${asmFile}" ]; then
                    echo "Error: '${asmFile}' not found"
                    echo "Please make sure '${asmFile}' is a file that exists in 'src'"
                    exit 1
                  fi
                '';

              buildPhase =
                args.buildPhase or ''
                  runHook preBuild

                  nasm -f elf32 "${asmFile}" -o "${name}.o"
                  mold "${name}.o" -o "${name}"

                  runHook postBuild
                '';

              installPhase =
                args.installPhase or ''
                  runHook preInstall

                  mkdir -p "$out/bin"

                  cp ${name} $out/bin/${name}

                  runHook postInstall
                '';

              meta.mainProgram = name;
            };
        };
      };
    }
  );
}
