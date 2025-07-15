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
  version = "1.7.4";

  src = fetchFromGitHub {
    owner = "etkecc";
    repo = "baibot";
    rev = "v${version}";
    hash = "sha256-G100YemvIiBkbYd8VSTzvh5AOnt2kjsjVKI4N1kFkwY=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-N6sJk8ndw6z3UtTFM26H6kCg3lgV16FChf+V5mLA2GQ=";

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
