{
  description = "Prebuild cross-toolchains for various targets";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs";

  outputs = { self, nixpkgs }: let
    pkgsCross = nixpkgs.legacyPackages.x86_64-linux.pkgsCross;
    inherit (nixpkgs) lib;
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
    hydraJobs = lib.mapAttrs (_: arch: arch.stdenv) self.packages.x86_64-linux;
  };
}
