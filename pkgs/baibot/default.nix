{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
  sqlite,
  stdenv,
  darwin,
}:

rustPlatform.buildRustPackage rec {
  pname = "baibot";
  version = "1.5.1";

  src = fetchFromGitHub {
    owner = "etkecc";
    repo = "baibot";
    rev = "v${version}";
    hash = "sha256-Rviurl+Baythcl92EjhqWBEAlaOg9L+HOjwEzEcG5DE=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-07U1MmVRmIJWy2AWYHBZSyY/D1PJo8OProYDnZbAdng=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs =
    [
      openssl
      sqlite
    ]
    ++ lib.optionals stdenv.isDarwin [
      darwin.apple_sdk.frameworks.Security
      darwin.apple_sdk.frameworks.SystemConfiguration
    ];

  meta = {
    description = "A Matrix bot for using diffent capabilities (text-generation, text-to-speech, speech-to-text, image-generation, etc.) of AI / Large Language Models (OpenAI, Anthropic, etc";
    homepage = "https://github.com/etkecc/baibot";
    changelog = "https://github.com/etkecc/baibot/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.agpl3Only;
    mainProgram = "baibot";
  };
}
