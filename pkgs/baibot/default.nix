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
  version = "1.4.1";

  src = fetchFromGitHub {
    owner = "etkecc";
    repo = "baibot";
    rev = "v${version}";
    hash = "sha256-LeLdKedwyjSubZ5vEqI+YmqTsd5+Ai+2Pof/I9HpgNQ=";
  };

  cargoHash = "sha256-C4c/LqFKqayx9e0Q57ZPOBeMyJapZN8BpdvXK7wbyxM=";

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
