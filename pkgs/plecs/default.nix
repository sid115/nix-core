{
  stdenv,
  fetchurl,
  makeWrapper,
  qt6,
  ncurses,
  zlib,
  coreutils,
  patchelf,
}:

stdenv.mkDerivation rec {
  pname = "plecs-standalone";
  version = "4-8-3";

  src = fetchurl {
    url = "https://www.plexim.com/sites/default/files/packages/${pname}-${version}_linux64.tar.gz";
    sha256 = "056g7clf1fgskysdsx1lvvl9pyrkxhjq4xaj0cykkn6305f2qaqf";
  };

  plecsDesktop = ./plecs.desktop;
  plecsPng = ./plecs.png;

  nativeBuildInputs = [
    coreutils
    makeWrapper
    patchelf
  ];

  buildInputs = [
    qt6.qtbase
    ncurses
    zlib
  ];

  unpackPhase = ''
    tar xvf $src
  '';

  installPhase = ''
    # Install icon
    install -Dm644 ${plecsPng} $out/share/pixmaps/plecs.png

    # Make directory structure for main app
    mkdir -p $out/share/applications
    mkdir -p $out/opt/plecs
    mkdir -p $out/bin
    mkdir -p $out/share/licenses/plecs

    # Install desktop file
    install -m 664 ${plecsDesktop} $out/share/applications/plecs.desktop

    # Copy files to the plecs directory
    cp -r plecs/* $out/opt/plecs

    # Ensure the main executable is executable
    chmod +x $out/opt/plecs/PLECS.bin

    # Patch the binary's interpreter
    patchelf --set-interpreter "$(cat ${stdenv.cc}/nix-support/dynamic-linker)" $out/opt/plecs/PLECS.bin

    # Debug: List files in target directory
    echo "Listing files in $out/opt/plecs"
    ls -l $out/opt/plecs

    # Modify the PLECS script to use the Nix store paths
    substituteInPlace $out/opt/plecs/PLECS \
      --replace "dirname=`dirname \"$0\"`" "dirname=\"$out/opt/plecs\""

    # Adding debugging to PLECS script
    substituteInPlace $out/opt/plecs/PLECS \
      --replace 'appname=`basename "$0" | sed s,\.sh$,,`' 'set -x; appname=`basename "$0" | sed s,\.sh$,,`; echo "appname: $appname"; echo "dirname: $dirname"; ls -l $dirname'

    # Ensure the modified PLECS script is executable
    chmod +x $out/opt/plecs/PLECS

    # Create a wrapper script in $out/bin to launch the modified PLECS script
    makeWrapper $out/opt/plecs/PLECS $out/bin/plecs \
      --prefix LD_LIBRARY_PATH : "${qt6.qtbase}/lib:${ncurses}/lib:${zlib}/lib:$out/opt/plecs"

    # Install license
    install -m 664 plecs/license.txt $out/share/licenses/plecs/license.txt
  '';
}
