let
  inherit (lib) mkDefault;
in
{
  imports = [
    ../audio
    ../bluetooth
  ];
}
