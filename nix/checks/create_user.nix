{
  tests.createUser = {
    noArgs = ''
      no_args=$(create_user || true)

      if [ "$no_args" != "nok: no identifier provided" ]; then
        throw_inspect \
          "Passing no args did not produce the right error message" \
          "$no_args"
      fi
    '';
    tooManyArgs = ''
      too_many_args=$(create_user a b || true)

      if [ "$too_many_args" != "nok: no identifier provided" ]; then
        throw_inspect \
          "Passing too many args did not produce the right error message" \
          "$too_many_args"
      fi
    '';
    userFileAlreadyExists = ''
      mkdir test_user

      already_exists=$(create_user test_user || true)

      if [ "$already_exists" != "nok: user already exists" ]; then
        throw_inspect \
          "Trying to create a user that already exists did not produce the right error message:" \
          "$already_exists"
      fi
    '';
  };
}
