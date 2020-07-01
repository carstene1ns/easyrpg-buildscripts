#!/bin/bash

# abort on errors
set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $SCRIPT_DIR/../shared/import.sh

# Installation directory
set_workspace

msg " [1] Checking pspdev"

if [[ -z $PSPDEV || ! -d "$PSPDEV" ]]; then
	echo "Setup pspdev properly. \$PSPDEV needs to be set."
	exit 1
fi

msg " [2] Downloading generic libraries"

# zlib
rm -rf $ZLIB_DIR
download_and_extract $ZLIB_URL

# libpng
rm -rf $LIBPNG_DIR
download_and_extract $LIBPNG_URL

# freetype
#rm -rf $FREETYPE_DIR
#download_and_extract $FREETYPE_URL

# harfbuzz
#rm -rf $HARFBUZZ_DIR
#download_and_extract $HARFBUZZ_URL

# pixman
rm -rf $PIXMAN_DIR
download_and_extract $PIXMAN_URL

# expat
#rm -rf $EXPAT_DIR
#download_and_extract $EXPAT_URL

# libogg
rm -rf $LIBOGG_DIR
download_and_extract $LIBOGG_URL

# tremor
rm -rf $TREMOR_DIR
download_and_extract $TREMOR_URL

# mpg123
rm -rf $MPG123_DIR
download_and_extract $MPG123_URL

# libsndfile
rm -rf $LIBSNDFILE_DIR
download_and_extract $LIBSNDFILE_URL

# libxmp-lite
rm -rf $LIBXMP_LITE_DIR
download_and_extract $LIBXMP_LITE_URL

# speexdsp
rm -rf $SPEEXDSP_DIR
download_and_extract $SPEEXDSP_URL

# wildmidi
rm -rf $WILDMIDI_DIR
download_and_extract $WILDMIDI_URL

# opus
rm -rf $OPUS_DIR
download_and_extract $OPUS_URL

# opusfile
rm -rf $OPUSFILE_DIR
download_and_extract $OPUSFILE_URL

# fmt
rm -rf $FMT_DIR
download_and_extract $FMT_URL

# ICU
rm -rf $ICU_DIR
download_and_extract $ICU_URL

# icudata
rm -f $ICUDATA_FILES
download_and_extract $ICUDATA_URL

msg " [3] Downloading platform libraries"

rm -rf gLib2D-own/
download_and_extract https://github.com/carstene1ns/gLib2D/archive/own.tar.gz

download "https://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub"