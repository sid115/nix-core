{
  lib,
  python3,
  fetchPypi,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "freecad-mcp";
  version = "0.1.13";
  pyproject = true;

  src = fetchPypi {
    pname = "freecad_mcp";
    inherit version;
    hash = "sha256-/CCMTyaDt6XsG+mok12pIM0TwG86Vs4pxq/Zd5Ol6wg=";
  };

  build-system = [
    python3.pkgs.hatchling
  ];

  dependencies = with python3.pkgs; [
    mcp
  ];

  pythonImportsCheck = [
    "freecad_mcp"
  ];

  meta = {
    description = "Add your description here";
    homepage = "https://pypi.org/project/freecad-mcp/";
    license = lib.licenses.mit;
    mainProgram = "freecad-mcp";
  };
}
