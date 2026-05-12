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
        in
        {
          gcc = pkgs.mkShell {
            nativeBuildInputs = [
              pkgs.bison
              pkgs.ccache
              pkgs.clang-tools
              pkgs.cmakeCurses
              pkgs.curlMinimal
              pkgs.gcc_latest
              pkgs.ninja
              pkgs.pkg-config
              pkgs.xz
            ]
            ++ lib.optionals isLinux [
              pkgs.libsystemtap
              pkgs.linuxPackages.bcc
              pkgs.linuxPackages.bpftrace
            ];

            buildInputs = [
              pkgs.boost
              pkgs.capnproto
              pkgs.libevent
              pkgs.sqlite.dev
              pkgs.zeromq
            ];
          };
        }
      );
    };
}
