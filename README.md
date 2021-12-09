# Prebuild cross-toolchains for various targets

This flake provides a binary cache for various toolchains for targets `pkgsCross` for x86_64-linux.
The cache is at https://nix-community.cachix.org

Right now we build stdenv for:

- aarch64-multiplatform
- armv7l-hf-multiplatform
- riscv32
- riscv64
- avr
- s390x
- x86_64-netbsd
- gnu32
- ppc64
- wasi32
- mingw32
- mingwW64
