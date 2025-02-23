{
  lib,
  stdenv,
  autoPatchelfHook,
  makeWrapper,
  qt6,
  xcb-util-cursor,
  libGL,
  libX11,
  libGLU,
  freetype,
  fontconfig,
  zlib,
  gcc,
}:

stdenv.mkDerivation rec {
  pname = "plecs";
  version = "4.9.4";
  src = builtins.fetchTarball {
    url = "https://www.plexim.com/sites/default/files/packages/plecs-standalone-4-9-4_linux64.tar.gz";
    sha256 = "0hkkga1zfnghrivkiws3pqld7ihc3bg1gzx2dckzdd5jfbdd9kpm";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    qt6.wrapQtAppsHook
  ];

  buildInputs =
    [
      xcb-util-cursor
      libGL
      libX11
      libGLU
      freetype
      fontconfig
      zlib
      gcc.cc.lib
    ]
    ++ (with qt6; [
      qtbase
      qtwebengine
      qt5compat
      qtsvg
      qtwayland
      # qtx11extras # not in nixpkgs
      # qtpdf # not in nixpkgs
    ]);

  autoPatchelfFlags = [ "--ignore-missing=libQt6Pdf.so.6" ]; # TODO

  installPhase = ''
    mkdir -p $out/plecs $out/bin
    cp -r $src/* $out/plecs/
    chmod -R +w $out/plecs

    for exec in PLECS PLECS_server crashreporter qhelpgenerator webengine; do
      if [ -f "$out/plecs/$exec" ]; then
        makeWrapper $out/plecs/$exec $out/bin/$exec \
          --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}:$out/plecs/octave/lib/octave/4.4.1:$out/plecs/octave/lib" \
          "''${qtWrapperArgs[@]}"
      fi
    done

    # Octave wrapper if needed
    if [ -f "$out/plecs/octave/bin/octave" ]; then
      makeWrapper $out/plecs/octave/bin/octave $out/bin/plecs-octave \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}:$out/plecs/octave/lib/octave/4.4.1:$out/plecs/octave/lib" \
        "''${qtWrapperArgs[@]}"
    fi
  '';

  meta = {
    description = "PLECS Simulation Platform for Electrical and Multi-Domain Systems";
    homepage = "https://www.plexim.com";
    # license = lib.licenses.TODO;
    platforms = [ "x86_64-linux" ];
  };
}
