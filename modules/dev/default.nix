# modules/dev --- common settings for dev modules

{ pkgs, ... }:
{
  imports = [
    ./clojure.nix
    ./node.nix
    ./python.nix
  ];

  options = {};
  config = {};
}
