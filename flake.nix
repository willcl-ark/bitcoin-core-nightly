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
        }
      );
    };
}
