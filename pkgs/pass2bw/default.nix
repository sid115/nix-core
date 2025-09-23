{
  stdenv,
  lib,
  makeWrapper,
  python3,
  ...
}:

stdenv.mkDerivation rec {
  pname = "pass2bw";
  version = "0.1";

  src = ./.;

  dontBuild = true;
  doCheck = false;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin

    sed -e "s|python ./convert_csvs.py|python $out/bin/convert_csvs.py|" \
      ${src}/${pname}.sh > $out/bin/${pname}
    chmod +x $out/bin/${pname}

    cp ${src}/convert_csvs.py $out/bin/

    wrapProgram $out/bin/${pname} \
      --prefix PATH : ${lib.makeBinPath [ python3 ]}
  '';
}
