{ config, pkgs, ... }:

{
  home.packages = with pkgs; [ kitty ];

  programs.kitty = {
    enable = true;
 };
}