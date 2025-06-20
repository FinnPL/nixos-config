{ config, pkgs, inputs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      inputs.home-manager.nixosModules.default
      ../../modules/nixos/auto.nix
      ../../modules/nixos/stylix-config.nix
    ];
  
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nix.settings = {
    substituters = ["https://hyprland.cachix.org"];
    trusted-substituters = ["https://hyprland.cachix.org"];
    trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
  };

  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  };

  networking.hostName = "centaur";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.desktopManager.gnome.enable = true;

  environment.systemPackages = [pkgs.greetd.tuigreet];

  services.greetd = {
    enable = true;
    settings = {
      default_session = let
        tuigreet = "${lib.getExe pkgs.greetd.tuigreet}";
        baseSessionsDir = "${config.services.xserver.displayManager.sessionData.desktops}";
        xSessions = "${baseSessionsDir}/share/xsessions";
        waylandSessions = "${baseSessionsDir}/share/wayland-sessions";
        tuigreetOptions = [
          "--remember"
          "--remember-session"
          "--sessions ${waylandSessions}:${xSessions}"
          "--time"
#          "--theme 'border=#${config.colorScheme.palette.base0D};text=#${config.colorScheme.palette.base05};prompt=#${config.colorScheme.palette.base0E};time=#${config.colorScheme.palette.base0A};action=#${config.colorScheme.palette.base0B};button=#${config.colorScheme.palette.base05};container=#${config.colorScheme.palette.base00};input=#${config.colorScheme.palette.base08}'"
          "--cmd Hyprland"
          "--asterisks"
        ];
        flags = lib.concatStringsSep " " tuigreetOptions;
      in {
        command = "${tuigreet} ${flags}";
        user = "fpl";
      };
    };
  };
  
  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "ch";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "sg";

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
  };


  programs.zsh.enable = true;

  users.users.fpl = {
    isNormalUser = true;
    description = "fpl";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
    packages = with pkgs; [
    ];
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = {
      "fpl" = import ./home.nix;
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "25.05";
}
