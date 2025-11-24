{
  config,
  lib,
  ...
}:

let
  cfg = config.virtualisation.hugepages;

  inherit (lib)
    mkEnableOption
    mkOption
    optionals
    types
    ;
in
{
  options.virtualisation.hugepages = {
    enable = mkEnableOption "huge pages.";

    defaultPageSize = mkOption {
      type = types.strMatching "[0-9]*[kKmMgG]";
      default = "1M";
      description = "Default size of huge pages. You can use suffixes K, M, and G to specify KB, MB, and GB.";
    };

    pageSize = mkOption {
      type = types.strMatching "[0-9]*[kKmMgG]";
      default = "1M";
      description = "Size of huge pages that are allocated at boot. You can use suffixes K, M, and G to specify KB, MB, and GB.";
    };

    numPages = mkOption {
      type = types.ints.positive;
      default = 1;
      description = "Number of huge pages to allocate at boot.";
    };
  };

  config.boot.kernelParams = optionals cfg.enable [
    "default_hugepagesz=${cfg.defaultPageSize}"
    "hugepagesz=${cfg.pageSize}"
    "hugepages=${toString cfg.numPages}"
  ];
}
