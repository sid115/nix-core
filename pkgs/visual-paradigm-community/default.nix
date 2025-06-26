{
  fetchurl,
  stdenv,
  lib,
  makeWrapper,
  jdk,
}:

let
  v_patch = "17.2";
  version = "${v_patch}.20241101";

  # Possible values: ca1 usa10 usa11 usa13 usa14 uk3 uk5 germany5 germany6 france3
  server = "germany4";

in
stdenv.mkDerivation rec {
  pname = "visual-paradigm-community";
  inherit version;

  src = builtins.fetchTarball {
    url = "https://www.visual-paradigm.com/downloads/${server}/vpce/Visual_Paradigm_CE_Linux64_InstallFree.tar.gz";
    sha256 = "1xj4b8ydav90q3pnh1a0sqxvh1rz502s1sif7zxxyhkzh2fqj2vf";
  };

  # TODO
  # supplementaryFiles = {
  #   "visual-paradigm-community.install" = fetchurl {
  #     url = "https://raw.githubusercontent.com/aur-helpers/aur-pkgbuilds/master/visual-paradigm-community/visual-paradigm-community.install?raw=true";
  #     sha256 = "52d244345f2ce8080d2b20c8c75b3ef833dfe9c5d605cac7129013b087bf2806";
  #   };
  #   "visual-paradigm.desktop" = fetchurl {
  #     url = "https://raw.githubusercontent.com/aur-helpers/aur-pkgbuilds/master/visual-paradigm-community/visual-paradigm.desktop?raw=true";
  #     sha256 = "5cdc0f50573d805938172c1f35664aa264fc5964fd92daed09b467565a6347b1";
  #   };
  #   "visual-paradigm.png" = fetchurl {
  #     url = "https://raw.githubusercontent.com/aur-helpers/aur-pkgbuilds/master/visual-paradigm-community/visual-paradigm.png?raw=true";
  #     sha256 = "41517b5c2326c0ba2fe3b6647f9594f094ccf03185cf73cb87d6cf19b355ff15";
  #   };
  #   "LICENSE.txt" = fetchurl {
  #     url = "https://raw.githubusercontent.com/aur-helpers/aur-pkgbuilds/master/visual-paradigm-community/LICENSE.txt?raw=true";
  #     sha256 = "cd30460cb1c29f9f42723197dbe72b2537aaed09cc2d44dcb3e6868fb5dbf12b";
  #   };
  #   "x-visual-paradigm.xml" = fetchurl {
  #     url = "https://raw.githubusercontent.com/aur-helpers/aur-pkgbuilds/master/visual-paradigm-community/x-visual-paradigm.xml?raw=true";
  #     sha256 = "a3b898bc9c43cf54baa1c643c619ee172a8103cd15031d574380ca463eb1ec1c";
  #   };
  # };

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [ jdk ];

  # sourceRoot = "${src}/Visual_Paradigm_CE_${v_patch}";

  # unpackPhase = ''
  #   mkdir -p source
  #   tar -xzf $src -C source --strip-components=1
  #   mv source Visual_Paradigm_CE_${v_patch}
  # '';

  # TODO
  # cp ${supplementaryFiles."visual-paradigm.desktop"} $out/share/applications/visual-paradigm-community.desktop
  # cp ${supplementaryFiles."visual-paradigm.png"} $out/share/icons/hicolor/512x512/apps/visual-paradigm-community.png
  # cp ${supplementaryFiles."LICENSE.txt"} $out/share/licenses/${pname}/LICENSE
  # cp ${supplementaryFiles."x-visual-paradigm.xml"} $out/share/mime/packages/x-visual-paradigm.xml

  installPhase = ''
    mkdir -p $out/share/applications
    mkdir -p $out/share/icons/hicolor/512x512/apps
    mkdir -p $out/share/${pname}/Application
    mkdir -p $out/bin
    mkdir -p $out/share/licenses/${pname}
    mkdir -p $out/share/mime/packages

    cp -r $src/Application $out/share/${pname}/
    cp -r $src/.install4j $out/share/${pname}/

    makeWrapper $out/share/${pname}/Application/bin/Visual_Paradigm $out/bin/${pname} \
      --set INSTALL4J_JAVA_HOME_OVERRIDE "${jdk}" \
      --set app_home "$out/share/${pname}" \
      --add-flags "--vm ${jdk}/bin/java" \
      --prefix PATH : "${lib.makeBinPath [ jdk ]}"
  '';

  meta = with lib; {
    description = "UML design application (Community Edition)";
    homepage = "http://www.visual-paradigm.com/download/community.jsp";
    license = licenses.unfree;
    platforms = platforms.linux;
  };
}
