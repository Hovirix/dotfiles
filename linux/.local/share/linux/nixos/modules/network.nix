{ hostname, ... }:
{
  boot.initrd.systemd.network.wait-online.enable = false;
  systemd.services.NetworkManager-wait-online.enable = false;

  networking = {

    enableIPv6 = false;
    hostName = "${hostname}";
    firewall.checkReversePath = false; # For VPN access

    networkmanager = {
      enable = true;
      settings = {

        main = {
          plugins = "keyfile";
          dhcp = "internal";
          hostname-mode = "none";
          dns = "default";
          rc-manager = "symlink";
          firewall-backend = "none";
        };

        logging = {
          audit = false;
          level = "WARN";
        };

        connection = {
          "ipv4.dhcp-hostname" = "";
          "ipv6.dhcp-hostname" = "";
          "ipv4.dhcp-send-hostname" = false;
          "ipv6.dhcp-send-hostname" = false;
          "ipv6.ip6-privacy" = 2;
          "wifi.cloned-mac-address" = "random";
          "wifi.powersave" = 3;
        };

        device = {
          "ignore-carrier" = true;
          "wifi.backend" = "wpa_supplicant";
          "wifi.scan-rand-mac-address" = true;
        };
      };
    };
  };
}
