{ pkgs, ... }:
pkgs.writeShellApplication {
  name = "nixasm";
  runtimeInputs = with pkgs; [
    nasm
    mold
  ];
  text = ''
          print_help () {
          cat << EOF
    Nix Powered NASM Development Scripts

    Commands:
      build <file>         - Build binary from asm
      run <file> <args...> - Build and run asm file

    Examples:
      nixasm build server.asm
      nixasm run add_user.asm anthony
    EOF
          }
          if [ $# -lt 2 ]; then 
            print_help
            exit 1
          fi

          name="$(basename "''${2%.*}")"
          build_dir="$(mktemp -d)"

          case "$1" in
            build)
              echo "building binary $name..."
              nasm -f elf64 "$2" -o "$build_dir/$name.o"

              echo "linking binary $name..."
              mold "$build_dir/$name.o" -o "$name"
              ;;

            run)
              echo "building binary $name..."
              nasm -f elf64 "$2" -o "$build_dir/$name.o"

              echo "linking binary $name..."
              mold "$build_dir/$name.o" -o "$build_dir/$name"

              echo "running $name..."
              exec "$build_dir/$name" "''${@:3}"
              ;;

            *)
              print_help
              ;;
          esac
  '';
}
