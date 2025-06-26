{
  lib,
  stdenv,
  fetchFromGitHub,

  autoconf,
  automake,
  # autotools-dev,
  bc,
  bison,
  cmake,
  curl,
  flex,
  gawk,
  git,
  glib,
  gmp,
  gperf,
  expat, # libexpat,
  libmpc,
  mpfr, # libmpfr,
  libtool,
  ninja,
  patchutils,
  python3,
  # slirp,
  texinfo,
  zlib,
  coreutils,
  util-linux,
}:

stdenv.mkDerivation rec {
  pname = "neorv32-gnu-toolchain";
  version = "2025.06.13";

  src = fetchFromGitHub {
    owner = "riscv-collab";
    repo = "riscv-gnu-toolchain";
    rev = version;
    hash = "sha256-alizCErkGot6tOtRDrQj7T1zKcNnmfcp4QUc0jgms78=";
    fetchSubmodules = true;
  };

  patches = [
    ./disable-git-submodule.patch
  ];

  buildInputs = [
    autoconf
    automake
    curl
    python3
    libmpc
    mpfr
    gmp
    gawk
    bison
    flex
    texinfo
    gperf
    libtool
    patchutils
    bc
    zlib
    expat
    ninja
    git
    cmake
    glib
    (python3.withPackages (p: with p; [ pip ]))
    coreutils
    util-linux
  ];

  preConfigure = ''
    export PATH=${coreutils}/bin:${util-linux}/bin:$PATH
    chmod +x ./scripts/*
    chmod +x ./scripts/wrapper/*
  '';

  configurePhase = ''
    ./configure \
      --prefix=$out \
      --with-arch=rv32i_zicsr_zicntr \
      --with-abi=ilp32
  '';

  buildPhase = ''
    make
  '';

  installPhase = ''
    make install
  '';

  meta = {
    description = "GNU toolchain for RISC-V, including GCC";
    homepage = "https://github.com/riscv-collab/riscv-gnu-toolchain";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.all;
  };
}
