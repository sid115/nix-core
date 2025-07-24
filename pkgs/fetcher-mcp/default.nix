{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  makeWrapper,
  playwright-driver,
}:

buildNpmPackage rec {
  pname = "fetcher-mcp";
  version = "unstable-2025-06-26";

  src = fetchFromGitHub {
    owner = "jae-jae";
    repo = "fetcher-mcp";
    rev = "652ec7b4f79020fea4924d1edb916d1dbf8755fe";
    hash = "sha256-9tkZnY0d10ECoqp6gs1qTYbZFS6WqFtjwTAR+tHajng=";
  };

  npmDepsHash = "sha256-1Pw+W3OdtGmgu1n4nacwaX77nfRUdWWkorn/xuiBhkA=";

  nativeBuildInputs = [ makeWrapper ];

  makeWrapperArgs = [
    "--set-default"
    "PLAYWRIGHT_BROWSERS_PATH"
    "${playwright-driver.browsers}"
  ];

  meta = {
    description = "MCP server for fetch web page content using Playwright headless browser";
    homepage = "https://github.com/jae-jae/fetcher-mcp";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "fetcher-mcp";
    platforms = lib.platforms.all;
  };
}
