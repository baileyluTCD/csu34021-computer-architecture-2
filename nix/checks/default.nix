{ config, lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.tests = mkOption {
    description = ''
      Bash tests to run for this repository's asm packages
    '';
    type = types.attrsOf (types.attrsOf types.str);
  };

  config.perSystem =
    { pkgs, self', ... }:
    let
      prelude = ''
        set -euo pipefail

        mkdir $out

        throw () {
          if [ $# != 1 ]; then
            echo "Invalid arg count provided to 'throw'"
            echo "Expected one argument"
          fi

          printf "\033[31mError:\033[0m %s\n" "$1"
          exit 1
        }

        throw_inspect () {
          if [ $# != 2 ]; then
            echo "Invalid arg count provided to 'throw_inspect'"
            echo "Expected two arguments"
          fi

          printf "\033[31mError:\033[0m %s\nFound: '%s'\n" "$1" "$2"
          exit 1
        }
      '';

      writeTests =
        namespace: tests:

        lib.mapAttrsToList (
          test: script:
          let
            testName = "test-${namespace}-${test}";
          in
          {
            ${testName} =
              pkgs.runCommand "${testName}"
                {
                  nativeBuildInputs = lib.attrValues self'.packages;
                }
                ''
                  ${prelude}
                  ${script}
                '';
          }
        ) tests;
    in
    {
      checks = config.tests |> lib.mapAttrsToList writeTests |> lib.flatten |> lib.mergeAttrsList;
    };
}
