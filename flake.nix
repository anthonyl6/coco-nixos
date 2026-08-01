{
  description = "Nixos config flake";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };

    nixpkgs-stable = {
      url = "github:nixos/nixpkgs/nixos-25.11";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    awww = {
      url = "git+https://codeberg.org/LGFae/awww";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nh = {
      url = "github:nix-community/nh";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    helix = {
      type = "github";
      owner = "helix-editor";
      repo = "helix";
      ref = "master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hytale = {
      url = "github:JPyke3/hytale-launcher-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ghostty = {
      type = "github";
      owner = "ghostty-org";
      repo = "ghostty";
      ref = "main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # zed = {
    #   type = "github";
    #   owner = "zed-industries";
    #   repo = "zed";
    #   ref = "main";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    niri = {
      type = "github";
      owner = "niri-wm";
      repo = "niri";
      ref = "main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # stoa = {
    #   url = "github:bobrware/stoa-nix";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  outputs =
    { nixpkgs, ... }@inputs:
    {
      nixosConfigurations = builtins.listToAttrs (
        map
          (name: {
            name = name;
            value = nixpkgs.lib.nixosSystem {
              modules = [ ./hosts/${name} ];
              specialArgs =
                let
                  system = "x86_64-linux";
                  pkgs = import nixpkgs { inherit system; };
                  username = "tony";
                  fullName = "Anthony Loria";
                  email = "anthony@anthonyloria.dev";
                in
                {
                  inherit inputs;
                  inherit (pkgs) stdenv;
                  inherit username;
                  inherit fullName;
                  inherit email;
                  pkgs-fresh = import nixpkgs {
                    inherit system;
                    config.allowUnfree = true;
                  };
                  pkgs-stable = import inputs.nixpkgs-stable {
                    inherit system;
                    config.allowUnfree = true;
                  };
                };
            };
          })
          [
            "coco"
            "cocolaptop"
          ]
      );
    };
}
