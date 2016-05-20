attrs@{nixutil ? import <nixutil> {}, ...}:
nixutil.haskellMakeDefault attrs ./project.nix
