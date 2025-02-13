{
  lib,
  python3,
  fetchPypi,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "fastapi-analytics";
  version = "1.2.3";
  pyproject = true;

  src = fetchPypi {
    pname = "fastapi_analytics";
    inherit version;
    hash = "sha256-+i4iiM+J77DLEOos9XEkQJmmMCO55EgPAka7IWL0GLM=";
  };

  build-system = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  dependencies = with python3.pkgs; [
    fastapi
    requests
  ];

  optional-dependencies = with python3.pkgs; {
    build = [
      build
      twine
    ];
    dev = [
      pytest
    ];
  };

  pythonImportsCheck = [
    "fastapi"
  ];

  meta = {
    description = "Monitoring and analytics for FastAPI applications";
    homepage = "https://pypi.org/project/fastapi-analytics/";
    license = lib.licenses.mit;
    mainProgram = "fastapi-analytics";
  };
}
