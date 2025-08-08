{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  fetchNpmDeps,
  nix-update-script,
}:

buildNpmPackage (finalAttrs: {
  pname = "qwen-code";
  version = "unstable-2025-08-01";

  src = fetchFromGitHub {
    owner = "sid115";
    repo = "qwen-code";
    rev = "fac00e03f28557ba3d1040ece4bc509d0a8c9528";
    hash = "sha256-Bn+n+CeQh9Hqee0G7OfvQRFXV1WwozyRE02+u30eUS4=";
  };

  npmDeps = fetchNpmDeps {
    inherit (finalAttrs) src;
    hash = "sha256-1p3AIPBbFy+P9x+f1cdYuj8ctr735kP2eBJT1wO0is8=";
  };

  buildPhase = ''
    runHook preBuild

    npm run generate
    npm run bundle

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp -r bundle/* $out/
    substituteInPlace $out/gemini.js --replace '/usr/bin/env node' "$(type -p node)"
    ln -s $out/gemini.js $out/bin/qwen-code

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Qwen-code is a coding agent that lives in digital world";
    homepage = "https://github.com/QwenLM/qwen-code";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "qwen-code";
    platforms = lib.platforms.all;
  };
})
