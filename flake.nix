{
  description = "Prebuild cross-toolchains for various targets";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }: let
    pkgsCross = nixpkgs.legacyPackages.x86_64-linux.pkgsCross;
  in {
    packages.x86_64-linux = {
      inherit (pkgsCross)
        aarch64-multiplatform
        armv7l-hf-multiplatform
        riscv32
        riscv64
        avr
        s390x
        x86_64-netbsd
        gnu32
        ppc64
        wasi32
        mingw32
        mingwW64;
    };
    hydraJobs = nixpkgs.lib.mapAttrs (_: arch: arch.stdenv) self.packages.x86_64-linux;
  };
}
