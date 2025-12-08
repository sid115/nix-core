{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  fetchNpmDeps,
  nix-update-script,
  pkg-config,
  libsecret,
  jq,
}:

buildNpmPackage rec {
  pname = "qwen-code";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "QwenLM";
    repo = "qwen-code";
    rev = "v${version}";
    hash = "sha256-B7dL0pWSCPwPKwwTHycgC3/qHB66AUWZc62sen7U/7c=";
  };

  npmDeps = fetchNpmDeps {
    inherit src;
    hash = "sha256-Vz6zTdNWkM1tnDMW6wM8cRCaed1pLihX7hYB2DaVBYg=";
  };

  nativeBuildInputs = [
    jq
    pkg-config
  ];

  buildInputs = [
    libsecret
  ];

  postPatch = ''
    mkdir -p packages/cli/src/generated packages/core/src/generated

    cat > packages/cli/src/generated/git-commit.ts <<EOF
    export const GIT_COMMIT_INFO = 'v${version}';
    export const CLI_VERSION = '${version}';
    EOF
    cp packages/cli/src/generated/git-commit.ts packages/core/src/generated/git-commit.ts

    echo "console.log('Skipping git generation (handled by Nix)');" > scripts/generate-git-commit-info.js

    ${jq}/bin/jq 'del(.optionalDependencies)' package.json > package.json.tmp && mv package.json.tmp package.json

    if [ -f packages/core/package.json ]; then
      ${jq}/bin/jq 'del(.optionalDependencies)' packages/core/package.json > packages/core/package.json.tmp && mv packages/core/package.json.tmp packages/core/package.json
    fi

    npm pkg set scripts.prepare="echo skipping prepare"
  '';

  buildPhase = ''
    runHook preBuild

    npm run bundle

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/libexec/${pname} $out/bin

    npm prune --production --no-audit --no-fund

    cp -r node_modules $out/libexec/${pname}/

    rm -f $out/libexec/${pname}/node_modules/@qwen-code/qwen-code
    rm -f $out/libexec/${pname}/node_modules/@qwen-code/qwen-code-core
    rm -f $out/libexec/${pname}/node_modules/@qwen-code/sdk
    rm -f $out/libexec/${pname}/node_modules/@qwen-code/qwen-code-test-utils
    rm -f $out/libexec/${pname}/node_modules/qwen-code-vscode-ide-companion

    cp -r dist $out/libexec/${pname}/

    ln -s $out/libexec/${pname}/dist/cli.js $out/bin/qwen-code
    chmod +x $out/libexec/${pname}/dist/cli.js

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Qwen Code is a coding agent that lives in the digital world";
    homepage = "https://github.com/QwenLM/qwen-code";
    changelog = "https://github.com/QwenLM/qwen-code/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "qwen-code";
    platforms = lib.platforms.all;
  };
}
