{
  inputs = {
    nixpkgs.follows = "mineflake/nixpkgs";
    mineflake.url = "github:nix-community/mineflake";
  };
  outputs = { self, nixpkgs, mineflake, ... }:
    {
      nixosModules.default = {
        imports = [ ./default.nix ];
        nixpkgs.overlays = [ mineflake.overlays.default ];
      };
    };
}
