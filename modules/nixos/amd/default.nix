{ pkgs, ... }:

{
  boot.initrd.kernelModules = [ "amdgpu" ];

  environment.systemPackages = with pkgs; [
    lact
    nvtopPackages.amd
    rocmPackages.clr.icd
    rocmPackages.hipcc
    rocmPackages.miopen
    rocmPackages.rocm-runtime
    rocmPackages.rocm-smi
    rocmPackages.rocminfo

  ];

  # environment.variables.ROC_ENABLE_PRE_VEGA = "1"; # for Polaris

  hardware.amdgpu.opencl.enable = true;

  systemd.packages = with pkgs; [ lact ];
  systemd.services.lactd.wantedBy = [ "multi-user.target" ];
}
