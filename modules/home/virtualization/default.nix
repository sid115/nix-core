let
  uri = "qemu:///system";
in
{
  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ uri ];
      uris = [ uri ];
    };
  };

  home.shellAliases = {
    virsh = "virsh --connect ${uri}";
  };
}
