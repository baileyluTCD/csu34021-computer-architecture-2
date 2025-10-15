{ lib, ... }:
let
  tests = {
    noArgs = ''
      no_args=$(create_user || true)

      if [ "$no_args" != "nok: no identifier provided" ]; then
        throw "Passing no args did not produce the right error message"
      fi
    '';
    tooManyArgs = ''
      too_many_args=$(create_user a b || true)

      if [ "$too_many_args" != "nok: no identifier provided" ]; then
        throw "Passing too many args did not produce the right error message"
      fi
    '';
  };
in
{
  perSystem =
    { pkgs, self', ... }:
    let
      prelude = ''
        set -euo pipefail

        mkdir $out

        throw () {
          if [ $# != 1 ]; then
            echo "Invalid arg count provided to 'print_error'"
            echo "Expected one argument"
          fi

          printf "\033[31mError:\033[0m %s\n" "$1"
          exit 1
        }
      '';

      writeTest =
        { name, value }:
        let
          test = "test-create_user-${name}";
        in
        {
          "${test}" =
            pkgs.runCommand "${test}"
              {
                nativeBuildInputs = [ self'.packages.create_user ];
              }
              ''
                ${prelude}
                ${value}
              '';
        };

      checks = tests |> lib.attrsToList |> map writeTest |> lib.mergeAttrsList;
    in
    {
      inherit checks;
    };
}
