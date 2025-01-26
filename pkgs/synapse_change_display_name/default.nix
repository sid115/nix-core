{ stdenv, gcc, ... }:

let
  pname = "synapse_change_display_name";
  version = "1.0.0";
in
stdenv.mkDerivation {
  inherit pname version;

  src = ./.;

  buildInputs = [ gcc ];

  buildPhase = ''
    gcc -o ${pname} ${pname}.c
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp ${pname} $out/bin/
  '';

  meta = {
    description = "A program for updating MatrixS-Synapse display names";
  };
}
