{ config, pkgs, lib, ... }:

{
  home.username = "lhy1024";
  home.homeDirectory = "/home/lhy1024";
  #programs.home-manager.enable = true;
  home.packages = with pkgs;[
    neofetch
    zip
    xz
    unzip
    p7zip
    smartmontools

    #clash-verge-rev
    flclash
    proxychains-ng

    rustup
    gcc
    lld_20
    gdb
    jetbrains.rust-rover
    gnumake
    just
    nasm

    qemu_kvm
    virt-manager


    wechat-uos

  ];
  home.file.".cargo/env".text = ''
    export PATH="$HOME/.cargo/bin:$PATH"
  '';
  home.file.".proxychains/proxychains.conf".text = ''
    strict_chain
    quiet_mode
    proxy_dns

    [ProxyList]
    http 127.0.0.1 7890
    socks5 127.0.0.1 7890
  '';

  home.stateVersion = "25.05";
}
