{
  tests.createUser = {
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
}
