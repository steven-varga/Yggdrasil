# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "OSSP_uuid"
version = v"1.6.2"

# Collection of sources required to build FriBidi
sources = [
    "http://deb.debian.org/debian/pool/main/o/ossp-uuid/ossp-uuid_$(version).orig.tar.gz" =>
    "11a615225baa5f8bb686824423f50e4427acd3f70d394765bdff32801f0fd5b0"
]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir/uuid-*/
update_configure_scripts
./configure --prefix=$prefix --host=$target includedir="${prefix}/include/uuid"
make -j${nproc}
make install
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = supported_platforms()

# The products that we will ensure are always built
products(prefix) = [
    LibraryProduct(prefix, "libuuid", :libuuid)
]

# Dependencies that must be installed before this package can be built
dependencies = [

]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)
