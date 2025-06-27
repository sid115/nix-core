{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs,
}:

buildNpmPackage rec {
  pname = "gemini-cli";
  version = "unstable-2025-06-26";

  src = fetchFromGitHub {
    owner = "google-gemini";
    repo = "gemini-cli";
    rev = "c55b15f705d083e3dadcfb71494dcb0d6043e6c6";
    hash = "sha256-ruS/GJgbuMAToHzJott41QU2hA4nhCKW5Akp+dlNocw=";
  };

  npmDepsHash = "sha256-yoUAOo8OwUWG0gyI5AdwfRFzSZvSCd3HYzzpJRvdbiM=";

  preBuild = ''
    npm run bundle
  '';

  installPhase = ''
    mkdir -p $out/lib
    cp -Rv node_modules $out/lib/node_modules
    cp -Rv packages $out/lib/packages
    cp -Rv bundle $out/lib/bundle

    mkdir -p $out/bin
    makeWrapper ${nodejs}/bin/node $out/bin/gemini --add-flags "$out/lib/bundle/gemini.js"

    chmod +x $out/bin/gemini
  '';

  meta = {
    description = "An open-source AI agent that brings the power of Gemini directly into your terminal";
    homepage = "https://github.com/google-gemini/gemini-cli";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "gemini";
    platforms = lib.platforms.all;
  };
}
