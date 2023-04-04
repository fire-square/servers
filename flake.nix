{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";
    mineflake = {
      url = "github:nix-community/mineflake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, mineflake, ... }:
    {
      nixosModules.default = {
        imports = [ ./default.nix ];
        nixpkgs.overlays = [ mineflake.overlays.default ];
      };
    };
}
