{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 10;
    };
    efi.canTouchEfiVariables = true;
    timeout = 3;
  };

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelModules = [ "kvm-intel" ];#kvm,intel cpu|boot.kernelModules = [ "kvm-amd" ];amd cpu
  boot.kernelParams = [ "intel_iommu=on" ];#开启 IOMMU 支持，用于 PCI 直通,AMD 则改为 amd_iommu=on

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    open = false;
  };

  networking.hostName = "nixos";
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Shanghai";

  nix = {
    package = pkgs.nix;
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      substituters = [
        "https://cache.nixos.org/"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      connect-timeout = 5;
    };
  };

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "zh_CN.UTF-8";
    supportedLocales = [ "zh_CN.UTF-8/UTF-8" "en_US.UTF-8/UTF-8" ];
    extraLocaleSettings = {
      LC_ADDRESS = "zh_CN.UTF-8";
      LC_IDENTIFICATION = "zh_CN.UTF-8";
      LC_MEASUREMENT = "zh_CN.UTF-8";
      LC_MONETARY = "zh_CN.UTF-8";
      LC_NAME = "zh_CN.UTF-8";
      LC_NUMERIC = "zh_CN.UTF-8";
      LC_PAPER = "zh_CN.UTF-8";
      LC_TELEPHONE = "zh_CN.UTF-8";
      LC_TIME = "zh_CN.UTF-8";
    };
    inputMethod = {
      type = "fcitx5";
      enable = true;
      fcitx5.addons = with pkgs; [
        fcitx5-gtk
        kdePackages.fcitx5-qt
        fcitx5-chinese-addons
        fcitx5-rime
        kdePackages.fcitx5-configtool
        fcitx5-nord
        rime-data
      ];
    };
  };
  services.xserver.enable = false;
  programs.xwayland.enable = true;

  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  #启用并配置 libvirtd 服务
  virtualisation.libvirtd = {
    enable = true;
    extraConfig = ''
      unix_sock_group = "libvirt"
      unix_sock_rw_perms = "0770"
      auth_unix_rw = "none"
    '';
    qemu.package = pkgs.qemu_kvm;
    qemu.ovmf.enable = true;
  };

  users.groups.libvirt = {};
  users.users.lhy1024 = {
    isNormalUser = true;
    description = "lhy1024";
    extraGroups = [ "networkmanager" "wheel" "libvirt" "kvm" ];
    packages = with pkgs; [
      firefox
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    git
    wget
    home-manager

    libvirt
    OVMF#Sample UEFI firmware for QEMU and KVM

  ];
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    #为未打包的程序添加缺失的动态库
  ];
  programs.appimage.enable = true;
  programs.appimage.binfmt = true;


  fonts = {
    enableDefaultPackages = true;
    fontDir.enable = true;
    packages = with pkgs; [
      noto-fonts
      noto-fonts-emoji
      dejavu_fonts
      fira-code
      jetbrains-mono
      noto-fonts-cjk-sans  # 思源黑体
      noto-fonts-cjk-serif # 思源宋体
      wqy_microhei
      (runCommand "misans-font" {} ''
        mkdir -p $out/share/fonts/truetype
        cp ${./fonts/MiSans}/*.ttf $out/share/fonts/truetype/
      '')
      corefonts
      vistafonts
      #(texlive.combine { inherit (texlive) scheme-small mtextra; })
      nerd-fonts.fira-code
      nerd-fonts.hack
      nerd-fonts.jetbrains-mono
      nerd-fonts.droid-sans-mono
    ];
    fontconfig = {
      enable = true;

      # 设置全局默认字体
      defaultFonts = {
        sansSerif = [ "MiSans" "Noto Sans CJK SC" "WenQuanYi Micro Hei" ];
        serif = [ "Noto Serif" "Noto Serif CJK SC" ];
        monospace = [ "DejaVu Sans Mono" "Noto Sans Mono CJK SC" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
  system.autoUpgrade = {
    enable = true;
  };


  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  system.stateVersion = "25.05";

}
