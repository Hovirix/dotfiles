{
  services.gvfs.enable = true;
  programs.dconf.enable = true;
  security.pam.services.swaylock = { };
  services.dbus.implementation = "broker";
}
