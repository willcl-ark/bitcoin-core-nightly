# Bitcoin Core dependencies built from the heads of their upstream branches.
# Each is built with the nixpkgs toolchain, so a failure here means the
# upstream branch itself is broken rather than Bitcoin Core.
{ pkgs, inputs }:
let
  inherit (pkgs) stdenv;
  # Tarball inputs, such as the Boost snapshot, have no revision.
  nightlyVersion = src: "0-unstable-${src.shortRev or "snapshot"}";
in
rec {
  # Kitware's nightly binary, as CMake master changes daily and would otherwise
  # be rebuilt on every run. It lacks the nixpkgs patch that reads
  # NIXPKGS_CMAKE_PREFIX_PATH, so expose shell inputs through the standard
  # CMAKE_PREFIX_PATH instead.
  cmake = stdenv.mkDerivation {
    pname = "cmake";
    version = nightlyVersion inputs.cmake-bin;
    src = inputs.cmake-bin;
    nativeBuildInputs = [ pkgs.autoPatchelfHook ];
    dontConfigure = true;
    dontBuild = true;
    # cmake-gui needs X11 libraries and is never used here.
    installPhase = ''
      cp -r . $out
      rm $out/bin/cmake-gui
    '';
    setupHook = pkgs.writeText "cmake-nightly-setup-hook.sh" ''
      addCMakePrefixPath() {
        addToSearchPath CMAKE_PREFIX_PATH "$1"
      }
      addEnvHooks "$targetOffset" addCMakePrefixPath
    '';
  };

  pkgconf-unwrapped = stdenv.mkDerivation {
    pname = "pkgconf";
    version = nightlyVersion inputs.pkgconf-src;
    src = inputs.pkgconf-src;
    nativeBuildInputs = [ pkgs.meson pkgs.ninja ];
  };

  pkgconf = pkgs.pkgconf.override { pkg-config = pkgconf-unwrapped; };

  sqlite = stdenv.mkDerivation {
    pname = "sqlite";
    version = nightlyVersion inputs.sqlite-src;
    src = inputs.sqlite-src;
    configureFlags = [ "--disable-tcl" ];
  };

  capnproto = stdenv.mkDerivation {
    pname = "capnproto";
    version = nightlyVersion inputs.capnproto-src;
    src = inputs.capnproto-src;
    nativeBuildInputs = [ pkgs.cmake pkgs.ninja ];
    cmakeFlags = [ "-DBUILD_TESTING=OFF" ];
  };

  zeromq = stdenv.mkDerivation {
    pname = "zeromq";
    version = nightlyVersion inputs.zeromq-src;
    src = inputs.zeromq-src;
    nativeBuildInputs = [ pkgs.cmake pkgs.ninja pkgs.pkg-config ];
    cmakeFlags = [
      "-DBUILD_TESTS=OFF"
      "-DWITH_DOCS=OFF"
      # libzmq.pc joins these onto ${prefix}, so they must stay relative.
      "-DCMAKE_INSTALL_INCLUDEDIR=include"
      "-DCMAKE_INSTALL_LIBDIR=lib"
    ];
  };

  # The develop snapshot uses the b2 release layout, which Boost's CMake build
  # cannot use. Bitcoin Core only needs the headers and Boost's CMake config.
  boost = stdenv.mkDerivation {
    pname = "boost";
    version = nightlyVersion inputs.boost-src;
    src = inputs.boost-src;
    patches = [ ./patches/boost-multi_index-gcc16-stringop-overflow.patch ];
    nativeBuildInputs = [ pkgs.which ];
    configurePhase = ''
      patchShebangs bootstrap.sh tools/build/src/engine
      ./bootstrap.sh
    '';
    dontBuild = true;
    installPhase = "./b2 --prefix=$out --with-headers install";
  };
}
