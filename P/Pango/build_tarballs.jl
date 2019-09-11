# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "Pango"
version = v"1.44.6"

# Collection of sources required to build Pango
sources = [
    "http://ftp.gnome.org/pub/GNOME/sources/pango/$(version.major).$(version.minor)/pango-$(version).tar.xz" =>
    "3e1e41ba838737e200611ff001e3b304c2ca4cdbba63d200a20db0b0ddc0f86c"
]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir/pango-*/
mkdir build && cd build

FLAGS=()
if [[ "${target}" == *-apple-* ]]; then
    # We have FontConfig for macOS, so let's use it
    FLAGS+=(-Duse_fontconfig=true)
fi

meson .. -Dintrospection=false "${FLAGS[@]}" --cross-file="${MESON_TARGET_TOOLCHAIN}"
ninja -j${nproc}
ninja install
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = supported_platforms()

# The products that we will ensure are always built
products = [
    LibraryProduct("libpango", :libpango),
    LibraryProduct("libpangocairo", :libpangocairo),
]

# Dependencies that must be installed before this package can be built
dependencies = [
    "FriBidi_jll",
    "FreeType2_jll",
    "Glib_jll",
    "Fontconfig_jll",
    "HarfBuzz_jll",
    "Cairo_jll",
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)
