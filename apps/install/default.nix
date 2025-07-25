{
  writeShellApplication,
  git,
  ...
}:

let
  name = "install";
  text = builtins.readFile ./${name}.sh;
in
writeShellApplication {
  inherit name text;
  meta.mainProgram = name;

  runtimeInputs = [
    git
  ];
}
