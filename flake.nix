{
  description = "Prebuild cross-toolchains for various targets";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs";

  outputs = { self, nixpkgs }: let
    pkgsCross = nixpkgs.legacyPackages.x86_64-linux.pkgsCross;
    inherit (nixpkgs) lib;

    # those are known to build
    goPlatforms = [
      "aarch64-multiplatform"
      "armv7l-hf-multiplatform"
      "ben-nanonote"
      "gnu32"
      "gnu64"
      "musl-power"
      "musl32"
      "musl64"
      "muslpi"
      "pogoplug4"
      "powernv"
      "raspberryPi"
      "remarkable1"
      "remarkable2"
      "riscv64"
      "s390x"
      "scaleway-c1"
      "sheevaplug"
      "x86_64-netbsd"
    ];
    stdenv-jobs = lib.mapAttrs'
      (name: arch: lib.nameValuePair "stdenv.${name}" arch.stdenv)
      self.packages.x86_64-linux;

    go-jobs = lib.mapAttrs'
      (name: arch: lib.nameValuePair "go.${name}" arch.buildPackages.go)
      (lib.getAttrs goPlatforms self.packages.x86_64-linux);

    clang-jobs = lib.mapAttrs'
      (name: arch: lib.nameValuePair "clang.${name}" arch.buildPackages.clang)
      self.packages.x86_64-linux;
  in {
    packages.x86_64-linux = lib.filterAttrs (n: v:
      !(
        (lib.hasPrefix "iphone" n)   || # not supported on Linux
        (lib.hasSuffix "darwin" n)   || # not supported on Linux
        n == "amd64-netbsd"          || # deprecated alias
        n == "x86_64-netbsd-llvm"    || # this is unfinished buisness
        n == "fuloongminipc"         || # some definition conflict broken with glibc <-> kernelHeaders
        n == "vc4"                   || # binutils/gcc broken; clevera wants to fix it
        false
      )
    ) pkgsCross;
    hydraJobs = stdenv-jobs // go-jobs // clang-jobs;
  };
}
