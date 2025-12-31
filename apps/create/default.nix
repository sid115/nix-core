{
  stdenv,
  coreutils,
  ...
}:

stdenv.mkDerivation rec {
  pname = "create";
  version = "2.0";

  src = ./.;

  nativeBuildInputs = [ coreutils ];

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share

    cp create.sh $out/bin/${pname}
    chmod +x $out/bin/${pname}
  '';

  meta.mainProgram = "create";
}
