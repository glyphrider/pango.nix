# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, inputs, ... }:

  let
    hyprland-flake-pkgs = inputs.hyprland.packages.${pkgs.system};
  in {

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.initrd.luks.devices."luks-33cd13e9-3173-4886-ae21-852f01263370".device = "/dev/disk/by-uuid/33cd13e9-3173-4886-ae21-852f01263370";

  boot.initrd.kernelModules = [ "amdgpu" ];

  zramSwap = {
    enable = true;
  };

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "US/Eastern";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "amdgpu" ];

  services.greetd = {
    enable = true;
    settings = rec {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet -c start-hyprland";
      };
    };
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  hardware.enableRedistributableFirmware = true;

  hardware.graphics = {
    enable32Bit = true;
    # extraPackages = with pkgs; [ amdvlk ];
    # extraPackages32 = with pkgs; [ driversi686Linux.amdvlk ];
  };

  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.brian = {
    isNormalUser = true;
    description = "Brian H. Ward";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" ];
    packages = with pkgs; [
    ];
  };

  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  };
  programs.hyprlock.enable = true;
  programs.waybar.enable = true;

  # Install firefox.
  programs.firefox.enable = true;

  programs.steam.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [

    inputs.hyprpaper.packages.${pkgs.stdenv.hostPlatform.system}.hyprpaper
    inputs.home-manager.packages.${pkgs.stdenv.hostPlatform.system}.home-manager
    
    inputs.rose-pine-hyprcursor.packages.${pkgs.stdenv.hostPlatform.system}.default

    pkgs.vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    pkgs.git
    # needed for neovim
    pkgs.neovim
    pkgs.ripgrep
    pkgs.clang
    pkgs.clang-tools
    pkgs.unzip
    pkgs.wl-clipboard
    pkgs.pavucontrol
    pkgs.htop
    # needed for hyprland
    pkgs.kitty
    pkgs.kdePackages.dolphin
    pkgs.wofi
    pkgs.dunst
    # needed for my zsh config
    pkgs.oh-my-posh
    # needed for fish
    pkgs.fishPlugins.done
    pkgs.fishPlugins.fzf-fish
    pkgs.fishPlugins.forgit
    pkgs.fishPlugins.hydro
    pkgs.fzf
    pkgs.fishPlugins.grc
    pkgs.grc
    # rust
    rustc
    cargo
  ];

  programs.neovim = {
    #viAlias = true;
    vimAlias = true;
  };

  programs.fish = {
    enable = true;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ls = "eza --icons=auto --color=auto --classify=auto --group-directories-first --git";
      ll = "eza --icons=auto --color=auto --classify=auto --group-directories-first --git --long";
      update = "sudo nixos-rebuild switch --flake .";
    };

    histSize = 10000;
    histFile = "$HOME/.zsh_history";
    setOptions = [
      "HIST_IGNORE_ALL_DUPS"
    ];
  };

  security.sudo.extraRules = [
    { groups = [ "wheel" ];
      commands = [ { command = "ALL"; options = [ "NOPASSWD" ]; } ];
    }
  ];

  fonts.enableDefaultPackages = true;
  fonts.packages = with pkgs; [
    liberation_ttf
    noto-fonts
    noto-fonts-color-emoji
    liberation_ttf
  ] ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);
 
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}
