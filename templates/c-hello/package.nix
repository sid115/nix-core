{
  stdenv,
}:

stdenv.mkDerivation rec {
  pname = "hello"; # FIXME: replace with your package name
  version = "0.1";

  src = ./.;

  installPhase = ''
    mkdir -p $out/bin
    cp build/${pname} $out/bin/
  '';
}
