{
  stdenv,
  lib,
  makeWrapper,
}:

stdenv.mkDerivation rec {
  pname = "cpntools";
  version = "2.3.5";

  src = builtins.fetchTarball {
    url = "https://cpntools.org/downloads/cpntools_${version}.tar.gz";
    sha256 = "";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  dontBuild = true;
  dontCheck = true;

  meta = with lib; {
    description = "A tool for editing, simulating, and analyzing Colored Petri nets";
    homepage = "https://cpntools.org/";
    # license = licenses.unfree;
    platforms = platforms.linux;
  };
}
