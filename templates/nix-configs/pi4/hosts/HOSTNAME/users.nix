{ inputs, ... }:

{
  imports = [
    inputs.core.nixosModules.normalUsers

    ../../users/USERNAME
  ];
}
