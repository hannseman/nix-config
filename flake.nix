{
  description = "a hannessystem";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-22.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-22.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      # System types to support.
      supportedSystems = [ "aarch64-darwin" ];
      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);
      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        }
      );
    in
    {
      homeConfigurations = {
        "hannes@arche" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgsFor.aarch64-darwin;
          extraSpecialArgs = { inherit inputs; };
          modules = [
            ./home
            rec {
              home.stateVersion = "22.11";
              home.username = "hannes";
              home.homeDirectory = "/Users/${home.username}";
            }
          ];
        };
      };
      devShells = forAllSystems (system:
        let pkgs = nixpkgsFor.${system};
        in with pkgs; {
          default = mkShell {
            # Enable experimental features without having to specify the argument
            NIX_CONFIG = "experimental-features = nix-command flakes";
            packages = [ pkgs.nix pkgs.home-manager pkgs.git pkgs.cargo pkgs.libiconv pkgs.nixfmt ];
          };
        }
      );
    };
}
