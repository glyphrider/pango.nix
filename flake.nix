{
  description = "My Hyprland and home-manager flake";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs?ref=nixos-unstable";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland = {
      url = "github:hyprwm/Hyprland";
    };
    hyprpaper = {
      url = "github:hyprwm/hyprpaper";
      inputs.nixpkgs.follows = "hyprland/nixpkgs";
    };
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
    rose-pine-hyprcursor = {
      url = "github:ndom91/rose-pine-hyprcursor";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.hyprlang.follows = "hyprland/hyprlang";
    };
  };

  outputs = { self, nixpkgs, home-manager, hyprland, hyprpaper, hyprland-plugins, ... } @ inputs:

  let
    system = "x86_64-linux";
    pkgs = import inputs.nixpkgs { system = "${system}"; config.allowUnfree = true; };
    home-manager-pkgs = import inputs.home-manager { system = "${system}"; };
  
  in {

    nixosConfigurations = {
      pango = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [ ./pango.nix ];
      };
    };
    homeConfigurations = {
      "brian" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit inputs; };
        modules = [ ./home.nix ];
      };
    };
  };
}
