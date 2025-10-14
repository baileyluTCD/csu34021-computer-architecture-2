{ flake-parts-lib, lib, ... }:
{
  options.perSystem = flake-parts-lib.mkPerSystemOption (
    { self', pkgs, ... }:
    {
      options.mkNixAsmDerivation = lib.mkOption {
        description = "nixasm derivation builder";
        default =
          let
            nixasm = self'.packages.nixasm;
          in
          lib.extendMkDerivation {
            constructDrv = pkgs.stdenvNoCC.mkDerivation;

            extendDrvArgs =
              _finalAttrs:
              { asmFile, ... }@args:
              assert lib.assertMsg (builtins.isString asmFile) ''
                `asmFile` must be a string to search for in the root
                of the `src` directory.
              '';

              let
                stringDropEnd =
                  n: string:
                  let
                    chars = lib.stringToCharacters string;
                    dropped = lib.dropEnd n chars;
                  in
                  lib.concatStrings dropped;

                extension = ".asm";
                extensionLen = lib.stringLength extension;
                name = stringDropEnd extensionLen (builtins.baseNameOf asmFile);
              in

              assert lib.assertMsg (lib.hasSuffix extension asmFile) ''
                `asmFile` must end in ".asm"
              '';

              {
                inherit name;

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

                    ${lib.getExe nixasm} build ${asmFile}

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
