{
  writeShellScriptBin,
  symlinkJoin,
  git,
  ...
}:

let
  wrapped = writeShellScriptBin "install" (builtins.readFile ./install.sh);
in
symlinkJoin {
  name = "install";
  paths = [
    wrapped
    git
  ];
}
