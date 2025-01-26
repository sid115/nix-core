{
  lib,
  stdenv,
  fetchFromGitLab,
  cmake,
  root,
  eigen,
}:

stdenv.mkDerivation rec {
  pname = "corryvreckan";
  version = "2.0";

  src = fetchFromGitLab {
    domain = "gitlab.cern.ch";
    owner = "corryvreckan";
    repo = "corryvreckan";
    rev = "v${version}";
    hash = "sha256-CP0KLnYCVirptluH6+q3RdMmZ2gJB+0olhixqUoZrWU=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    root
    eigen
  ];

  meta = with lib; {
    description = "The Maelstrom for Your Test Beam Data - http://cern.ch/corryvreckan";
    homepage = "https://gitlab.cern.ch/corryvreckan/corryvreckan";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "corryvreckan";
    platforms = platforms.all;
  };
}
