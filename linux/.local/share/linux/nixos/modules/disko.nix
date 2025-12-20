{
  disko.devices.disk.nixos = {
    type = "disk";
    device = "/dev/disk/by-id/nvme-CT1000P3SSD8_2321E6DBFB5A";

    content = {
      type = "gpt";
      partitions = {

        boot = {
          size = "1G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "defaults" "umask=0077" ];
          };
        };

        root = {
          size = "100%";
          content = {
            type = "luks";
            name = "crypted";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
              mountOptions = [ "defaults" "noatime" "nodiratime" ];
            };
          };
        };
      };
    };
  };
}
