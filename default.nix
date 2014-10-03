let
  nixpkgs = (import <nixpkgs> {}).fetchgit {
    url    = https://github.com/nixos/nixpkgs.git;
    rev    = "d34cd13a317dd0df5af9f3a67ad22e9ea8f9e505";
    sha256 = "b3287ba562a7b97dbb239935b868f0e7d9f73a0c6acba96d17e6f6818d1bb7bc";
  };
in
{ haskellPackages ? (import nixpkgs { config.allowUnfree = true; }).haskellPackages_ghc783
, pname ? "wait-handle"
, src ? ./.
}:
let
  inherit (haskellPackages) cabal cabalInstall;
in cabal.mkDerivation (_:{
  inherit pname src;
  version = "0.1";
  buildTools = [cabalInstall];
})
