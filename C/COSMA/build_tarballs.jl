# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "COSMA"
version = v"1.0"

# Collection of sources required to build CImGui
sources = [
    "https://github.com/eth-cscs/COSMA/releases/download/$(version.major).$(version.minor)/cosma.tar.gz" =>
    "c142104258dcca4c17fa7faffc2990a08d2777235c7980006e93c5dca51061f6",
]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir/cosma/
mkdir build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=${prefix} \
    -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TARGET_TOOLCHAIN} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCOSMA_BLAS=OPENBLAS \
    -DCOSMA_WITH_OPENBLAS=ON
make -j${nproc}
make install
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = filter(p -> !isa(p, Windows), supported_platforms())

# The products that we will ensure are always built
products = Product[
]

# Dependencies that must be installed before this package can be built
dependencies = [
    "OpenBLAS_jll",
    "OpenMPI_jll",
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)
