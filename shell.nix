{ pkgs ? import <nixpkgs> {} }:

let
  nodejs = pkgs.nodejs-16_x;

  easyPS = import ./nix/easy-purescript.nix { inherit pkgs; };
in
  pkgs.mkShell {
    buildInputs = [
      easyPS.purs-0_14_7
      easyPS.spago
      easyPS.zephyr
      easyPS.spago2nix
      nodejs
      pkgs.nodePackages.node2nix
    ];

    shellHook = ''
      export PATH=$PWD/node_modules/.bin:$PATH
    '';
  }
