# Prebuild cross-toolchains for various targets

This flake provides a binary cache for various toolchains for targets `pkgsCross` for x86_64-linux.
The binary cache is at https://nix-community.cachix.org

Right now we build stdenv all targets in [lib/systems/examples.nix](https://github.com/NixOS/nixpkgs/blob/master/lib/systems/examples.nix)
except for some broken targets filtered in [flake.nix](https://github.com/nix-community/cross-toolchains.nix/blob/main/flake.nix).

Our goal is to catch regressions and pin nixpkgs to a known working state.
