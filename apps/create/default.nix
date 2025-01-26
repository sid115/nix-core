{
  writeShellScriptBin,
  symlinkJoin,
  ...
}:

let
  wrapped = writeShellScriptBin "create" (builtins.readFile ./create.sh);
in
symlinkJoin {
  name = "create";
  paths = [
    wrapped
  ];
}
