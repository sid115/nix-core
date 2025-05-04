{
  stdenv,
  bash,
  coreutils,
  fzf,
  tree,
  ...
}:

stdenv.mkDerivation rec {
  pname = "cdf";
  version = "0.1";

  src = ./.;

  buildInputs = [
    bash
    coreutils
    fzf
    tree
  ];

  installPhase = ''
    mkdir -p $out/bin

    cp ${pname}.sh $out/bin/${pname}
    chmod +x $out/bin/${pname}
  '';
}
