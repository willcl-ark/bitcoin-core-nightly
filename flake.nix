{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    boost-src = {
      url = "https://archives.boost.io/develop/boost_1_93_0-snapshot.tar.gz";
      flake = false;
    };
    capnproto-src = {
      url = "github:capnproto/capnproto/release-1.5.0";
      flake = false;
    };
    cmake-bin = {
      url = "https://cmake.org/files/dev/cmake-4.5.20261118-g9aa6566-linux-x86_64.tar.gz";
      flake = false;
    };
    pkgconf-src = {
      url = "github:pkgconf/pkgconf/main";
      flake = false;
    };
    sqlite-src = {
      url = "github:sqlite/sqlite/master";
      flake = false;
    };
    zeromq-src = {
      url = "github:zeromq/libzmq/master";
      flake = false;
    };
  };

  outputs =
    { nixpkgs, ... }@inputs:
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
          nightly = import ./nightly-deps.nix { inherit pkgs inputs; };
          cmake = if system == "x86_64-linux" then
            pkgs.stdenvNoCC.mkDerivation rec {
              pname = "kitware-cmake-bin";
              version = "4.3.2";

              src = pkgs.fetchurl {
                url = "https://github.com/Kitware/CMake/releases/download/v${version}/cmake-${version}-linux-x86_64.tar.gz";
                hash = "sha256-eRrjYEhBygPLOImjrYkWU0bksYCuNEjv1LDKqe9G0kU=";
              };

              sourceRoot = "cmake-${version}-linux-x86_64";
              nativeBuildInputs = [ pkgs.autoPatchelfHook ];
              buildInputs = [ pkgs.glibc ];

              installPhase = ''
                runHook preInstall

                mkdir -p "$out"
                cp -R . "$out"
                rm -f "$out/bin/cmake-gui"
                rm -rf "$out/doc"

                runHook postInstall
              '';
            }
          else
            pkgs.cmakeCurses;
          commonNativeBuildInputs = [
            pkgs.bison
            pkgs.ccache
            pkgs.clang-tools
            cmake
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

          nightly-deps = pkgs.mkShell {
            nativeBuildInputs = [
              pkgs.ccache
              nightly.cmake
              pkgs.ninja
              nightly.pkgconf
              pkgs.python316
            ];

            buildInputs = [
              nightly.boost
              nightly.capnproto
              nightly.sqlite
              nightly.zeromq
            ];
          };
        }
      );
    };
}
