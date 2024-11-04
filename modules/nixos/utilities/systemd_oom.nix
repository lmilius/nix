{ lib, ... }:
{
  # OOM configuration:
  systemd = {
    # Create a separate slice for nix-daemon that is
    # memory-managed by the userspace systemd-oomd killer
    slices."nix-daemon".sliceConfig = {
      ManagedOOMMemoryPressure = "kill";
      ManagedOOMMemoryPressureLimit = "95%";
    };
    services = {
      "nix-daemon".serviceConfig = {
        Slice = "nix-daemon.slice";

        # If a kernel-level OOM event does occur anyway,
        # strongly prefer killing nix-daemon child processes
        OOMScoreAdjust = 1000;
      };
      # Refer to: https://github.com/NixOS/nixpkgs/issues/59603
      # and: https://github.com/NixOS/nixpkgs/issues/180175
      NetworkManager-wait-online.enable = lib.mkDefault false;
    };
  };
}