{ pkgs, unstablePkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    bitwarden-cli
    btop
    curl
    dig
    docker-compose
    diffr # Modern Unix `diff`
    difftastic # Modern Unix `diff`
    dua # Modern Unix `du`
    duf # Modern Unix `df`
    du-dust # Modern Unix `du`
    git
    gparted
    htop
    iotop
    iperf3
    ipmitool
    jq
    kmon
    nmap
    pciutils
    powertop
    smartmontools
    tmux
    traceroute
    trippy
    unzip
    usbutils
    vim
    watch
    wget
  ];
}
