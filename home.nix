{ config, pkgs, inputs, ... }:

{
  home.username = "brian";
  home.homeDirectory = "/home/brian";

  home.stateVersion = "25.05"; # Please read the comment before changing.

  programs.home-mananger.enable = true;
}
