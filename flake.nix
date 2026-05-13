{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          lib = pkgs.lib;
          isLinux = pkgs.stdenv.hostPlatform.isLinux;
          llvm = pkgs.llvmPackages_latest;
          commonNativeBuildInputs = [
            pkgs.bison
            pkgs.ccache
            pkgs.clang-tools
            pkgs.cmakeCurses
            pkgs.curlMinimal
            pkgs.ninja
            pkgs.pkg-config
            pkgs.xz
          ]
          ++ lib.optionals isLinux [
            pkgs.libsystemtap
            pkgs.linuxPackages.bcc
            pkgs.linuxPackages.bpftrace
          ];
          commonBuildInputs = [
            pkgs.boost
            pkgs.capnproto
            pkgs.libevent
            pkgs.sqlite.dev
            pkgs.zeromq
          ];
        in
        {
          gcc = pkgs.mkShell {
            nativeBuildInputs = commonNativeBuildInputs ++ [
              pkgs.gcc_latest
            ];

            buildInputs = commonBuildInputs;
          };

          libcxx = pkgs.mkShell {
            nativeBuildInputs = commonNativeBuildInputs ++ [
              llvm.clang
            ];

            buildInputs = commonBuildInputs ++ [
              llvm.libcxx
            ];

            shellHook = ''
              export CC=clang
              export CXX=clang++
              export CXXFLAGS="-stdlib=libc++ ''${CXXFLAGS:-}"
              export LDFLAGS="-stdlib=libc++ ''${LDFLAGS:-}"
            '';
          };

          clang-sanitizer = pkgs.mkShell {
            nativeBuildInputs = commonNativeBuildInputs ++ [
              llvm.clang
            ];

            buildInputs = commonBuildInputs ++ [
              llvm.compiler-rt
            ];

            shellHook = ''
              export CC=clang
              export CXX=clang++
            '';
          };
        }
      );
    };
}
