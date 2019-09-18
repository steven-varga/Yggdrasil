# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder, Pkg.BinaryPlatforms

name = "GTK3"
version = v"3.24.11"

# Collection of sources required to build GTK
sources = [
    "http://ftp.gnome.org/pub/gnome/sources/gtk+/$(version.major).$(version.minor)/gtk+-$(version).tar.xz" =>
    "dba7658d0a2e1bfad8260f5210ca02988f233d1d86edacb95eceed7eca982895",
]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir/gtk+-*/

mkdir build-gtk
cd build-gtk

# We need to run some commands with a native Glib
apk add glib-dev
# This is awful, I know
rm ${prefix}/bin/glib-compile-resources
ln -s /usr/bin/glib-compile-resources ${prefix}/bin/glib-compile-resources

meson .. \
    -Dx11_backend=false \
    -Dwayland_backend=false \
    -Dintrospection=false \
    -Ddemos=false \
    -Dexamples=false \
    -Dtests=false \
    --cross-file="${MESON_TARGET_TOOLCHAIN}"
ninja -j${nproc}
ninja install
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [p for p in supported_platforms() if p isa MacOS]

# The products that we will ensure are always built
products = Product[
]

# Dependencies that must be installed before this package can be built
dependencies = [
    "Glib_jll",
    "Pango_jll",
    "gdk_pixbuf_jll",
    "ATK_jll",
    "adwaita_icon_theme_jll",
    "Cairo_jll",
    "HarfBuzz_jll",
    "Graphene_jll",
    "iso_codes_jll",
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)
