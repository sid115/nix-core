{
  writeShellApplication,
  ...
}:

let
  name = "bulk-rename";
  text = builtins.readFile ./${name}.sh;
in
writeShellApplication {
  inherit name text;
  meta.mainProgram = name;

  runtimeInputs = [
  ];
}
