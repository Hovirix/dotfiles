{ inputs, ... }:
{
  boot = {

    kernelPackages = inputs.chaotic.legacyPackages.${"x86_64-linux"}.linuxPackages_cachyos;

    kernelParams = [
      # Power saving
      "acpi=force"
      "pcie_aspm=force"
      "nowatchdog"
      "nmi_watchdog=0"
      "amd_pstate=active"
      "rcutree.enable_rcu_lazy=1"

      # Catppuccin mocha tty
      "vt.default_red=30,243,166,249,137,245,148,186,88,243,166,249,137,245,148,166"
      "vt.default_grn=30,139,227,226,180,194,226,194,91,139,227,226,180,194,226,173"
      "vt.default_blu=46,168,161,175,250,231,213,222,112,168,161,175,250,231,213,200"
    ];

    blacklistedKernelModules = [ "sp5100_tco" ];

    kernel.sysctl = {
      "kernel.kexec_load_disabled" = 1;
      "vm.swappiness" = 0; # I don't use Swap
      "vm.vfs_cache_pressure" = 50;
      "vm.dirty_bytes" = 268435456;
      "vm.dirty_writeback_centisecs" = 1500;
      "vm.dirty_background_bytes" = 67108864;
    };
  };

  # services.scx = {
  #   enable = true;
  #   scheduler = "scx_lavd";
  #   extraArgs = [ "--autopower" ];
  # };
}
