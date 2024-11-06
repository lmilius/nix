{ pkgs, unstablePkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    autorestic
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
    openssl
    pciutils
    powertop
    python311Full
    python311Packages.virtualenv
    python311Packages.pip
    restic
    smartmontools
    # unstablePkgs.tailscale
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
