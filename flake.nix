{
  description = "Prebuild cross-toolchains for various targets";

  inputs.nixpkgs.url = "github:Mic92/nixpkgs";

  outputs = { self, nixpkgs }: let
    pkgsCross = nixpkgs.legacyPackages.x86_64-linux.pkgsCross;
    inherit (nixpkgs) lib;

    # those are known to build
    clangPlatforms = [
      "aarch64-android"
      "aarch64-multiplatform-musl"
      "aarch64-multiplatform"
      "armv7l-hf-multiplatform"
      "gnu32"
      "m68k"
      "mingw32"
      "mingwW64"
      "musl-power"
      "musl32"
      "musl64"
      "or1k"
      "pogoplug4"
      "powernv"
      "ppc64-musl"
      "ppc64"
      "ppcle-embedded"
      "pogoplug4"
      "powernv"
      "ppc64-musl"
      "ppc64"
      "ppcle-embedded"
      "remarkable1"
      "remarkable2"
      "riscv64"
      "s390"
      "s390x"
      "scaleway-c1"
      "sheevaplug"
      "wasi32"
      "x86_64-unknown-redox"
    ];
    stdenv-jobs = lib.mapAttrs'
      (name: arch: lib.nameValuePair "pkgsCross.${name}.stdenv" arch.stdenv)
      self.packages.x86_64-linux;

    hello-jobs = lib.mapAttrs'
      (name: arch: lib.nameValuePair "pkgsCross.${name}.hello" arch.hello)
      (lib.filterAttrs (n: v: !(
        v.stdenv.targetPlatform.parsed.kernel.name != "none" || # no executable support
        n == "x86_64-unknown-redox"                          || # no wprintf
        true
      )) self.packages.x86_64-linux);

    brokenGoPlatforms = [
      "s390"
      "mmix"
      "mingw32"
      "mingwW64"
      "m68k"
      "ghcjs"
      "x86_64-unknown-redox"
      "wasi32"
      "ppc64-musl"
      "ppc64"
      "riscv32"

      "armv7a-android-prebuilt"
      "aarch64-android"
      "aarch64-android-prebuilt"
    ];
    substractAttrs = keys: attrs: lib.getAttrs (lib.subtractLists keys (builtins.attrNames attrs)) attrs;

    pkgsWithOS = lib.filterAttrs
      (n: v: v.targetPlatform.parsed.kernel.name != "none")
      self.packages.x86_64-linux;

    go-jobs = lib.mapAttrs'
      (name: arch: lib.nameValuePair "pkgsCross.${name}.go" arch.buildPackages.go)
      (substractAttrs brokenGoPlatforms pkgsWithOS);

    clang-jobs = lib.mapAttrs'
      (name: arch: lib.nameValuePair "pkgsCross.${name}.clang" arch.buildPackages.clang)
      (lib.getAttrs clangPlatforms self.packages.x86_64-linux);

    rustc-jobs = lib.mapAttrs'
      (name: arch: lib.nameValuePair "pkgsCross.${name}.rustc" arch.buildPackages.rustc)
      (lib.getAttrs clangPlatforms self.packages.x86_64-linux);
  in {
    packages.x86_64-linux = lib.filterAttrs (n: v:
      !(
        (lib.hasPrefix "iphone" n)          || # not supported on Linux
        (lib.hasSuffix "darwin" n)          || # not supported on Linux
        n == "amd64-netbsd"                 || # deprecated alias
        n == "x86_64-netbsd-llvm"           || # this is unfinished buisness
        n == "fuloongminipc"                || # some definition conflict broken with glibc <-> kernelHeaders
        n == "vc4"                          || # binutils/gcc broken; clevera wants to fix it
        (lib.hasPrefix "mipsisa" n)         || # junk, never worked, should be not in nixpkgs
        n == "mipsel-linux-gnu"             || # junk, unknown abi o32
        n == "mips-linux-gnu"               || # junk, unknown abi o32
        n == "mips64el-linux-gnuabin32"     || # junk
        n == "mips64-linux-gnuabin32"       || # junk
        false
      )
    ) pkgsCross;
    hydraJobs = stdenv-jobs // hello-jobs // go-jobs // clang-jobs // rustc-jobs;
  };
}
