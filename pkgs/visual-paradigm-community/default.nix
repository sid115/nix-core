{
  stdenv,
  lib,
  makeWrapper,
  jdk11,
}:

let
  v_patch = "17.3";
  v_suffix = "20250906";
  version = "${v_patch}.${v_suffix}";

  underscores = s: builtins.replaceStrings [ "." ] [ "_" ] s;
in
stdenv.mkDerivation rec {
  pname = "visual-paradigm-community";
  inherit version;

  src = builtins.fetchTarball {
    url = "https://eu8.dl.visual-paradigm.com/visual-paradigm/vpce${v_patch}/${v_suffix}/Visual_Paradigm_CE_${underscores version}_Linux64_InstallFree.tar.gz";
    sha256 = "sha256:0hycxn2ndjs1pl3zhw33ykpxcc5ca077vrx0jdf8jk3kjlan44qx";
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
