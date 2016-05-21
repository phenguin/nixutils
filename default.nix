{ nixpkgs ? import <nixpkgs> {}}:
with nixpkgs; with builtins;
let allpkgs = nixpkgs; in
nixpkgs // rec {
  ifFlag = b: vals: if b then vals else [];

  addHaskellDevInputs = {pyDev ? false, jsDev ? false, util ? true, editors ? true,...}: attrs: attrs // (with attrs; rec {
    buildDepends = (with allpkgs.haskellPackages; [ cabal-install ghc-mod hlint hoogle haddock stylish-haskell hasktags ]) ++
                  ifFlag pyDev (with nixpkgs.python27Packages; [ python jedi elpy pip ipython ipdb ]) ++
                  ifFlag jsDev [ nodejs ] ++
                  ifFlag editors [ emacs vim ] ++
                  ifFlag util [ less sudo zsh fasd silver-searcher git tmux procps ] ++ (attrOrDefault attrs "buildDepends" []);
    shellHook = attrOrDefault attrs "shellHook" "" + ''
    export EMACS_SERVER_NAME=${attrs.pname}
    '';
  });

  addDevInputs = attrs@{pyDev ? false, jsDev ? false, util ? true, editors ? true,...}: attrs // (with attrs; rec {
    buildInputs = ifFlag pyDev (with nixpkgs.python27Packages; [ python jedi elpy pip ipython ipdb ]) ++
                  ifFlag jsDev [ nodejs ] ++
                  ifFlag editors [ emacs vim ] ++
                  ifFlag util [ less sudo zsh fasd silver-searcher git tmux procps ] ++ (attrOrDefault attrs "buildInputs" []);
    shellHook = attrOrDefault attrs "shellHook" "" + ''
    export EMACS_SERVER_NAME=${attrs.name}
    '';
  });

  mkDev = attrs: stdenv.mkDerivation (addDevInputs attrs);

  attrOrDefault = set: attrName: default:
    if hasAttr attrName set then getAttr attrName set else default;

  haskellMakeDefault = { nixpkgs ? nixpkgs, compiler ? "default", inputMod ? addHaskellDevInputs {}}: project:
    let
      pkgs = nixpkgs.pkgs;
      haskellPackages = if compiler =="default" then
                         pkgs.haskellPackages else pkgs.haskell.packages.${compiler};
    in haskellPackages.callPackage (import project {inputModifier = inputMod;}) {};

  haskellMakeShell = devSettings: { nixpkgs ? allpkgs, compiler ? "default" }: buildfile:
    let
      inherit (nixpkgs) haskellPackages;
      inputMod = addHaskellDevInputs devSettings;
     in
        (import buildfile { inherit nixpkgs compiler inputMod; }).env;

}
