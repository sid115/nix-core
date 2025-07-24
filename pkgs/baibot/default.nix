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
  version = "1.7.6";

  src = fetchFromGitHub {
    owner = "etkecc";
    repo = "baibot";
    rev = "v${version}";
    hash = "sha256-EdFTJBQmKdvOVvr0P6vf+UHtdQAamDeV1jVFOzcPDsY=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-RxHWsw0KtrhN2zJ+W0T/7t0kKwDOuRUOOR0tecMZ6Fk=";

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
