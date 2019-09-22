# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "Gobject-introspection"
version = v"1.62.0"

# Collection of sources required to build Gobject-introspection
sources = [
    "https://download.gnome.org/sources/gobject-introspection/$(version.major).$(version.minor)/gobject-introspection-$(version).tar.xz" =>
    "b1ee7ed257fdbc008702bdff0ff3e78a660e7e602efa8f211dc89b9d1e7d90a2",
]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir/gobject-introspection-*/
mkdir build && cd build

meson .. --cross-file="${MESON_TARGET_TOOLCHAIN}"
ninja -j${nproc}
ninja install
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = supported_platforms()

# The products that we will ensure are always built
products = Product[
]

# Dependencies that must be installed before this package can be built
dependencies = [
    "Glib_jll",
    "Python_jll",
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)
