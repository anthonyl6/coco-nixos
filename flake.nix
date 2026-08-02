{
  description = "Nixos config flake";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };

    nixpkgs-stable = {
      url = "github:nixos/nixpkgs/nixos-26.05";
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

    helix = {
      type = "github";
      owner = "helix-editor";
      repo = "helix";
      rev = "e7874bc69c0549fe87e863c4b4f6a5c2fccffca7";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ghostty = {
      type = "github";
      owner = "ghostty-org";
      repo = "ghostty";
      rev = "5540f5f249db0f5e8c1e5f47ee9339f4fe1786f0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # zed = {
    #   type = "github";
    #   owner = "zed-industries";
    #   repo = "zed";
    #   ref = "main";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    nix-flatpak = {
      url = "github:gmodena/nix-flatpak/v0.7.0";
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
