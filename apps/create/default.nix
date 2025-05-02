{
  stdenv,
  coreutils,
  ...
}:

stdenv.mkDerivation rec {
  pname = "create";
  version = "1.0";

  src = ./.;

  nativeBuildInputs = [ coreutils ];

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share

    cp create.sh $out/bin/${pname}
    chmod +x $out/bin/${pname}

    cp -r templates $out/share

    sed -i "s|^TEMPLATES_DIR.*|TEMPLATES_DIR=$out/share/templates|" $out/bin/${pname}
  '';
}
