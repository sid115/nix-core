{
  inputs,
  ...
}:

{
  imports = [
    inputs.core.nixosModules.openssh
  ];

  services.openssh.enable = true;
}
