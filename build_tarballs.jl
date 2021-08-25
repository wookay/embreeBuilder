# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder, Pkg

name = "embree"
version = v"3.13.1"

# Collection of sources required to complete build
sources = [
    ArchiveSource("https://github.com/embree/embree/archive/refs/tags/v3.13.1.tar.gz", "00dbd852f19ae2b95f5106dd055ca4b304486436ced0ccf842aec4e38a4df425")
]

# Bash recipe for building across all platforms
script = raw"""
apk add binutils  # objdump
cd $WORKSPACE/srcdir/embree*/
mkdir build && cd build/
cmake \
    -DCMAKE_INSTALL_PREFIX=$prefix \
    -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TARGET_TOOLCHAIN} \
    -DCMAKE_BUILD_TYPE=Release \
    -DEMBREE_MAX_ISA=NONE \
    -DEMBREE_ISPC_SUPPORT=OFF \
    -DEMBREE_TUTORIALS=OFF \
    ..
make
make install
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    Platform("x86_64", "linux"; libc = "glibc"),
    Platform("x86_64", "linux"; libc = "musl"),
    Platform("x86_64", "macos"; ),
    Platform("x86_64", "freebsd"; )
]


# The products that we will ensure are always built
products = [
    LibraryProduct("libembree3", :libembree3)
]

# Dependencies that must be installed before this package can be built
dependencies = [
    Dependency(PackageSpec(name="oneTBB_jll", uuid="1317d2d5-d96f-522e-a858-c73665f53c3e"))
    Dependency(PackageSpec(name="GLFW_jll", uuid="0656b61e-2033-5cc2-a64a-77c0f6c09b89"))
    Dependency(PackageSpec(name="JpegTurbo_jll", uuid="aacddb02-875f-59d6-b918-886e6ef4fbf8"))
    Dependency(PackageSpec(name="libpng_jll", uuid="b53b4c65-9356-5827-b1ea-8c7a1a84506f"))
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies; julia_compat="1.6")
