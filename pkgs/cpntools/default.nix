{
  lib,
  stdenv,
  wrapGAppsHook,
  gdk-pixbuf,
  glib,
  gtk2,
  libX11,
  libXcursor,
  libXext,
  libXft,
  libXi,
  libXinerama,
  libXrandr,
  libXrender,
  pango,
  zlib,
  fontconfig,
  freetype,
  openssl,
  pkgsi686Linux,
}:

stdenv.mkDerivation rec {
  pname = "cpntools";
  version = "2.3.5";

  src = builtins.fetchTarball {
    url = "https://cpntools.org/downloads/cpntools_${version}.tar.gz";
    sha256 = "sha256:1h5lqf6knwfmm0g15vh1a16aakk6fin3i4wzxbmby30nnl3sxrcd";
  };

  nativeBuildInputs = [
    wrapGAppsHook
  ];

  i686Libs = with pkgsi686Linux; [
    fontconfig
    freetype
    gdk-pixbuf
    glib
    glibc
    gtk2
    libX11
    libXcursor
    libXext
    libXft
    libXi
    libXinerama
    libXrandr
    libXrender
    libxml2
    openssl
    pango
    zlib
  ];

  buildInputs = [
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk2
    libX11
    libXcursor
    libXext
    libXft
    libXi
    libXinerama
    libXrandr
    libXrender
    openssl
    pango
    zlib
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/lib/cpntools
    cp -r ./* $out/lib/cpntools/

    # Create wrapper script
    mkdir -p $out/bin
    cat > $out/bin/cpntools <<EOF
    #!/bin/sh
    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$out/lib/cpntools"
    exec $out/lib/cpntools/cpntools "\$@"
    EOF
    chmod +x $out/bin/cpntools

    # Install fonts
    mkdir -p $out/share/fonts/truetype/cpntools
    cp fonts/*.ttf $out/share/fonts/truetype/cpntools/
    cp fonts/*.pfa $out/share/fonts/truetype/cpntools/

    runHook postInstall
  '';

  postFixup = ''
    mkdir -p $out/etc/fonts
    ln -s ${fontconfig.out}/etc/fonts/fonts.conf $out/etc/fonts/fonts.conf

    cpntools_bin="$out/lib/cpntools/cpntools"
    if [ -f "$cpntools_bin" ]; then
      patchelf \
        --set-interpreter "${pkgsi686Linux.glibc}/lib/ld-linux.so.2" \
        --set-rpath "${lib.makeLibraryPath i686Libs}" \
        "$cpntools_bin"
    fi

    cpnmld_bin="$out/lib/cpntools/cpnsim/cpnmld"
    if [ -f "$cpnmld_bin" ]; then
      patchelf \
        --set-interpreter "${pkgsi686Linux.glibc}/lib/ld-linux.so.2" \
        --set-rpath "${lib.makeLibraryPath i686Libs}" \
        "$cpnmld_bin"
    fi

    run_bin="$out/lib/cpntools/cpnsim/run.x86-linux"
    if [ -f "$run_bin" ] && file "$run_bin" | grep -q 'ELF.*executable'; then
      patchelf \
        --set-interpreter "${pkgsi686Linux.glibc}/lib/ld-linux.so.2" \
        --set-rpath "${lib.makeLibraryPath i686Libs}" \
        "$run_bin"
    fi
  '';

  meta = with lib; {
    description = "Computer-Aided Analysis of Coloured Petri Nets";
    homepage = "http://cpntools.org/";
    license = licenses.unfree;
    maintainers = with maintainers; [ ];
    platforms = [ "x86_64-linux" ];
  };
}
