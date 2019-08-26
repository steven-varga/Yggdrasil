using BinaryBuilder

name = "Glib"
version = v"2.59.3"

# Collection of sources required to build Glib
sources = [
    "https://ftp.gnome.org/pub/gnome/sources/glib/$(version.major).$(version.minor)/glib-$(version).tar.xz" =>
    "dfefafbc37bbcfb8101f3f181f880e8b7a8bee48620c92869ec4ef1d3d648e5e",
    "https://github.com/mesonbuild/meson/releases/download/0.51.1/meson-0.51.1.tar.gz" =>
    "f27b7a60f339ba66fe4b8f81f0d1072e090a08eabbd6aa287683b2c2b9dd2d82",
]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir/glib-*/
MESON="$(readlink -f ../meson-0.*/meson.py)"
mkdir build
cd build

# Get a local gettext for msgfmt cross-building
apk add gettext

if [[ ${target} == *apple-darwin* ]]; then
    export AR=/opt/${target}/bin/${target}-ar
fi


case ${target} in
    *-linux-*)
	HOST_MACHINE_SYSTEM="linux"
	;;
    *-freebsd*)
	HOST_MACHINE_SYSTEM="freebsd"
	;;
    *-apple-*)
	HOST_MACHINE_SYSTEM="darwin"
	;;
    *-mingw32)
	HOST_MACHINE_SYSTEM="windows"
	;;
esac
case ${target} in
    x86_64-*)
	HOST_MACHINE_CPU_FAMILY="x86_64"
	;;
    i686-*)
	HOST_MACHINE_CPU_FAMILY="x86"
	;;
    aarch64-*)
	HOST_MACHINE_CPU_FAMILY="aarch64"
	;;
    arm-*)
	HOST_MACHINE_CPU_FAMILY="arm"
	;;
    powerpc64le-*)
	HOST_MACHINE_CPU_FAMILY="ppc64"
	;;
esac
case ${target} in
    x86_64-*|i686-*|powerpc64le-*)
	HOST_MACHINE_CPU="i686"
	;;
    aarch64-*|arm-*)
	HOST_MACHINE_CPU="arm"
	;;
esac

cat > cross_compile.txt << EOF
[binaries]
c = '${CC}'
cpp = '${CXX}'
ar = '${AR}'
strip = '${STRIP}'
pkgconfig = '/usr/bin/pkg-config'

[properties]
c_args = ['-I$prefix/include']
c_link_args = ['-L${prefix}/lib', '${LDFLAGS}']
cpp_args = ['-I$prefix/include']
cpp_link_args = ['-L${prefix}/lib', '${LDFLAGS}']

[host_machine]
system = '${HOST_MACHINE_SYSTEM}'
cpu_family = '${HOST_MACHINE_CPU_FAMILY}'
cpu = '${HOST_MACHINE_CPU}'
endian = 'little'

[target_machine]
system = 'linux'
cpu_family = 'x86_64'
cpu = 'i686'
endian = 'little'

[paths]
prefix = '${prefix}'
libdir = 'lib'
bindir = 'bin'
EOF

CC="${HOSTCC}"
CXX="${HOSTCXX}"
AR="${AR_FOR_BUILD}"
STRIP="${STRIP_FOR_BUILD}"
LDFLAGS=""
OBJC="${CC} -ObjC"

$MESON .. -Diconv=gnu -Dlibmount=false --cross-file cross_compile.txt

ninja
ninja install
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = supported_platforms()

# Disable FreeBSD for now

# The products that we will ensure are always built
products(prefix) = [
    LibraryProduct(prefix, "libglib", :libglib)
]

# Dependencies that must be installed before this package can be built
dependencies = [
    # We need zlib
    "https://github.com/bicycle1885/ZlibBuilder/releases/download/v1.0.4/build_Zlib.v1.2.11.jl",
    # We need libffi
    "https://github.com/JuliaPackaging/Yggdrasil/releases/download/Libffi-v3.2.1-0/build_Libffi.v3.2.1.jl",
    # We need gettext
    "https://github.com/JuliaPackaging/Yggdrasil/releases/download/Gettext-v0.19.8-0/build_Gettext.v0.19.8.jl",
    # We need pcre
    "https://github.com/JuliaPackaging/Yggdrasil/releases/download/PCRE-v8.42-2/build_PCRE.v8.42.0.jl",
    # We need iconv
    "https://github.com/JuliaPackaging/Yggdrasil/releases/download/Libiconv-v1.15-0/build_Libiconv.v1.15.0.jl",
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)
