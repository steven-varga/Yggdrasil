# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "NetCDF"
version = v"4.7.2"

# Collection of sources required to build NetCDF
sources = [
    "https://github.com/Unidata/netcdf-c/archive/v$(version)/netcdf-$(version).tar.gz" =>
    "7648db7bd75fdd198f7be64625af7b276067de48a49dcdfd160f1c2ddff8189c",
]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir/netcdf-*/
mkdir build && cd build

cmake .. -DCMAKE_INSTALL_PREFIX=${prefix} \
    -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TARGET_TOOLCHAIN} \
    -DCMAKE_BUILD_TYPE=Release \
    -DENABLE_CDF5=ON
make -j${nproc}
make install
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    Linux(:x86_64),
    Linux(:i686),
    MacOS(),
    Windows(:x86_64),
    Windows(:i686),
]

# The products that we will ensure are always built
products = [
    LibraryProduct("libnetcdf", :libnetcdf),
]

# Dependencies that must be installed before this package can be built
dependencies = [
    "HDF5_jll",
    "LibCURL_jll",
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)
