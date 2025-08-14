{
  stdenv,
  lib,
  makeWrapper,
  jdk11,
}:

let
  v_patch = "17.2";
  version = "${v_patch}.20250617";

  # Possible values: ca1 usa10 usa11 usa13 usa14 uk3 uk5 germany5 germany6 france3
  server = "germany4";
in
stdenv.mkDerivation rec {
  pname = "visual-paradigm-community";
  inherit version;

  src = builtins.fetchTarball {
    url = "https://www.visual-paradigm.com/downloads/${server}/vpce/Visual_Paradigm_CE_Linux64_InstallFree.tar.gz";
    sha256 = "0mx5z05jyxncg1hpn3qjskpfz4b28i380bc0qlmf42kg80r1ydcw";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  dontBuild = true;
  dontCheck = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/${pname}
    mkdir -p $out/bin

    cp -r $src/Application $out/share/${pname}/
    cp -r $src/.install4j $out/share/${pname}/

    local vp_script="$out/share/${pname}/Application/bin/Visual_Paradigm"

    substituteInPlace "$vp_script" \
      --replace "app_home=../../" "app_home=$out/share/${pname}"

    makeWrapper "$vp_script" $out/bin/${pname} \
      --set INSTALL4J_JAVA_HOME "${jdk11}" \
      --set INSTALL4J_ADD_VM_PARAMS "-Djava.io.tmpdir=/tmp" \
      --set-default __GL_MaxFramesAllowed 1 \
      --add-flags "--add-modules=java.se"

    runHook postInstall
  '';

  meta = with lib; {
    description = "UML design application (Community Edition)";
    homepage = "http://www.visual-paradigm.com/download/community.jsp";
    license = licenses.unfree;
    platforms = platforms.linux;
  };
}
