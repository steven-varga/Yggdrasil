# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

# Collection of sources required to build Cuba
name = "OpenMPI"
version = v"4.0.2"

sources = [
    "https://download.open-mpi.org/release/open-mpi/v$(version.major).$(version.minor)/openmpi-$(version).tar.bz2" =>
    "900bf751be72eccf06de9d186f7b1c4b5c2fa9fa66458e53b77778dffdfe4057",
]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir/openmpi-*/
./configure --prefix=${prefix} --host=${target}
ln -s /opt/${target}/${target} ${prefix}/${target}
make -j${nproc}
make install
rm ${prefix}/${target}
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = expand_gfortran_versions(supported_platforms())

# The products that we will ensure are always built
products = Product[
]

# Dependencies that must be installed before this package can be built
dependencies = []

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)
