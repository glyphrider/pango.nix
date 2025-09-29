{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland = {
      url = "github:hyprwm/Hyprland";
    };
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };

  };

  outputs = { self, nixpkgs, home-manager, hyprland, hyprland-plugins, ... } @ inputs:

  let
    system = "x86_64-linux";
    pkgs = import inputs.nixpkgs { system = "${system}"; config.allowUnfree = true; };
  
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
        extraSpecialArgs = {
          inherit inputs;
        };
        modules = [ ./home.nix ];
      };
    };
  };
}
