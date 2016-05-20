attrs@{nixutil ? import <nixutil> {}, ...}:
nixutil.haskellMakeShell {} attrs ./default.nix
