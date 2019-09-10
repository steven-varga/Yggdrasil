using BinaryBuilder

name = "Glib"
version = v"2.62.0"

# Collection of sources required to build Glib
sources = [
    "https://ftp.gnome.org/pub/gnome/sources/glib/$(version.major).$(version.minor)/glib-$(version).tar.xz" =>
    "6c257205a0a343b662c9961a58bb4ba1f1e31c82f5c6b909ec741194abc3da10",
]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir/glib-*/
mkdir build && cd build

# Get a local gettext for msgfmt cross-building
apk add gettext

meson .. --cross-file="${MESON_TARGET_TOOLCHAIN}"
ninja -j${nproc}
ninja install
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = supported_platforms()

# The products that we will ensure are always built
products = [
    LibraryProduct("libgio", :libgio),
    LibraryProduct("libglib", :libglib),
    LibraryProduct("libgmodule", :libgmodule),
    LibraryProduct("libgobject", :libgobject),
    LibraryProduct("libgthread", :libgthread),
]

# Dependencies that must be installed before this package can be built
dependencies = [
    "Libffi_jll",
    "Libmount_jll",
    "Gettext_jll",
    "PCRE_jll",
    "Zlib_jll",
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)
