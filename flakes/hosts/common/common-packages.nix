{ pkgs, unstablePkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    autorestic
    bitwarden-cli
    btop
    ctop
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
    inetutils
    iotop
    iperf3
    ipmitool
    jq
    kmon
    lazydocker
    lshw
    nmap
    openssl
    pciutils
    powertop
    python311Full
    python311Packages.virtualenv
    python311Packages.pip
    restic
    s-tui
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
