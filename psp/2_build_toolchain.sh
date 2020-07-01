#!/bin/bash

# abort on error
set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $SCRIPT_DIR/../shared/import.sh

# Installation directory
#set_workspace
export WORKSPACE=$PWD

# Number of CPU
nproc=$(nproc)

# Use ccache?
test_ccache

# Toolchain available?
if [[ -z $PSPDEV || ! -d "$PSPDEV" ]]; then
	echo "Setup pspdev properly. \$PSPDEV needs to be set."
	exit 1
fi

if [ ! -f .patches-applied ]; then
	echo "Patching libraries"

	patches_common

	# Fix tremor
	(cd $TREMOR_DIR
		patch -Np1 < ../tremor.patch
	)

	# Fix mpg123
	(cd $MPG123_DIR
		patch -Np1 < ../mpg123.patch
		autoreconf -fi
	)

	# Fix libsndfile
	(cd $LIBSNDFILE_DIR
		patch -Np1 < $SCRIPT_DIR/../shared/extra/libsndfile.patch
		# do not fortify source
		perl -pi -e 's/AX_ADD_FORTIFY_SOURCE//' configure.ac
		autoreconf -fi
	)

	# make autotools recognize psp
	find . -mindepth 2 -name config.sub -exec cp config.sub '{}' \;

	cp -rup icu icu-native

	touch .patches-applied
fi

cd $WORKSPACE

echo "Preparing toolchain"

export PATH=$PSPDEV/bin:$PATH

export PLATFORM_PREFIX=$WORKSPACE
export TARGET_HOST=psp
unset PSP_PKG_CONFIG_PATH
export PSP_PKG_CONFIG_LIBDIR=$PLATFORM_PREFIX/lib/pkgconfig
export MAKEFLAGS="-j${nproc:-2}"

function set_build_flags {
	export CC="psp-gcc"
	export CXX="psp-gcc"
	if [ "$ENABLE_CCACHE" ]; then
		export CC="ccache $CC"
		export CXX="ccache $CXX"
	fi
	export CFLAGS="-O2 -g0 -G0 -ffunction-sections"
	export CXXFLAGS="$CFLAGS"
	export CPPFLAGS="-D__PSP__ -I$PLATFORM_PREFIX/include -I$(psp-config --pspsdk-path)/include"
	export LDFLAGS="-L$PLATFORM_PREFIX/lib -L$(psp-config --pspsdk-path)/lib -L$(psp-config --psp-prefix)/lib"
	export LIBS="-lstdc++ -lc -lpspuser"
}

function install_lib_gLib2D {
	msg "Building gLib2D"

	cd gLib2D-own
	make clean
	make JPEG=0 PNG=0 VFPU=0
	cp glib2d.h $WORKSPACE/include
	cp libglib2d.a $WORKSPACE/lib
	cd ..
}

install_lib_icu_native

set_build_flags

install_lib_zlib
install_lib $LIBPNG_DIR $LIBPNG_ARGS
#install_lib $FREETYPE_DIR $FREETYPE_ARGS --without-harfbuzz
#install_lib $HARFBUZZ_DIR $HARFBUZZ_ARGS
#install_lib $FREETYPE_DIR $FREETYPE_ARGS --with-harfbuzz
install_lib $PIXMAN_DIR $PIXMAN_ARGS
install_lib_cmake $EXPAT_DIR $EXPAT_ARGS
install_lib $LIBOGG_DIR $LIBOGG_ARGS
install_lib $TREMOR_DIR $TREMOR_ARGS
install_lib_mpg123
install_lib $LIBSNDFILE_DIR $LIBSNDFILE_ARGS
install_lib_cmake $LIBXMP_LITE_DIR $LIBXMP_LITE_ARGS
install_lib $SPEEXDSP_DIR $SPEEXDSP_ARGS
install_lib_cmake $WILDMIDI_DIR $WILDMIDI_ARGS
install_lib $OPUS_DIR $OPUS_ARGS
install_lib $OPUSFILE_DIR $OPUSFILE_ARGS
install_lib_cmake $FMT_DIR $FMT_ARGS
install_lib_icu_cross
install_lib_gLib2D
