{
  inputs = {
    nixpkgs.follows = "mineflake/nixpkgs";
    mineflake.url = "github:nix-community/mineflake";
  };
  outputs = { self, nixpkgs, mineflake, ... }:
    {
      nixosModules.default = import ./default.nix;
    };
}
