{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  makeWrapper,
  playwright-driver,
  linkFarm,
  jq,
  ...
}:
let
  revision = "1161";

  chromium-headless-shell =
    playwright-driver.passthru.components."chromium-headless-shell".overrideAttrs
      (old: {
        inherit revision;
      });

  browsers-headless-only = linkFarm "playwright-browsers-headless-only" [
    {
      name = "chromium-${revision}";
      path = chromium-headless-shell;
    }
  ];
in
buildNpmPackage rec {
  pname = "fetcher-mcp";
  version = "0.3.6";

  src = fetchFromGitHub {
    owner = "jae-jae";
    repo = "fetcher-mcp";
    rev = "4f4ad0f723367a7b0d3215c01d04282d573e6980";
    hash = "sha256-4Hh2H2ANBHOYYl3I1BqrkdCPNF/1hgv649CqAy7aiYw=";
  };

  env.PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";

  nativeBuildInputs = [
    makeWrapper
    jq
  ];

  npmDepsHash = "sha256-a56gDzZCo95vQUO57uFwMc9g/7jweYdCKqx64W8D1T8=";

  postPatch = ''
    jq 'del(.scripts.postinstall) | del(.scripts."install-browser")' package.json > package.json.tmp && mv package.json.tmp package.json
  '';

  makeWrapperArgs = [
    "--set"
    "PLAYWRIGHT_BROWSERS_PATH"
    "${browsers-headless-only}"
    # "--set"
    # "PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS"
    # "true"
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
