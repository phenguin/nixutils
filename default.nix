{ nixpkgs ? import <nixpkgs> {}}:
with nixpkgs; with builtins;
nixpkgs // rec {
  ifFlagThen = b: vals: if b then vals else [];
  mkDev = attrs@{pyDev ? false, jsDev ? false, editors ? true,...}: stdenv.mkDerivation (attrs // (with attrs; rec {
    buildInputs = ifFlagThen pyDev (with nixpkgs.python27Packages; [ python jedi elpy pip ipython ]) ++
                  ifFlagThen jsDev [ nodejs ] ++
                  ifFlagThen editors [ emacs vim ] ++
                  [ zsh fasd git tmux procps ] ++ attrs.buildInputs;
    shellHook = attrOrDefault attrs "shellHook" "" + ''
    export EMACS_SERVER_NAME=${attrs.name}
    '';
  }));
  attrOrDefault = set: attrName: default:
    if hasAttr attrName set then getAttr attrName set else default;
}
