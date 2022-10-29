##############################################################
# All needed libraries for all common platforms              #
# Some platforms override them in <platform>/libraries.cmake #
##############################################################

set(ZLIB_VER 1.2.13)
set(ZLIB_URL "https://zlib.net/zlib-${ZLIB_VER}.tar.xz")
set(ZLIB_SHA256 d14c38e313afc35a9a8760dadf26042f51ea0f5d154b0630a31da0540107fb98)

set(LIBPNG_VER 1.6.38)
set(LIBPNG_URL "https://download.sourceforge.net/libpng/libpng-${LIBPNG_VER}.tar.xz")
set(LIBPNG_SHA256 b3683e8b8111ebf6f1ac004ebb6b0c975cd310ec469d98364388e9cedbfa68be)
set(LIBPNG_OPTIONS -DPNG_SHARED=OFF -DPNG_EXECUTABLES=OFF -DPNG_TESTS=OFF)

set(FREETYPE_VER 2.12.1)
set(FREETYPE_URL "https://download.savannah.gnu.org/releases/freetype/freetype-${FREETYPE_VER}.tar.xz")
set(FREETYPE_SHA256 4766f20157cc4cf0cd292f80bf917f92d1c439b243ac3018debf6b9140c41a7f)
set(FREETYPE_OPTIONS -DFT_DISABLE_ZLIB=TRUE -DFT_DISABLE_BZIP2=TRUE -DFT_DISABLE_PNG=TRUE -DFT_DISABLE_BROTLI=TRUE)

set(HARFBUZZ_VER 3.0.0) # 5.4
set(HARFBUZZ_URL "https://github.com/harfbuzz/harfbuzz/releases/download/${HARFBUZZ_VER}/harfbuzz-${HARFBUZZ_VER}.tar.xz")
set(HARFBUZZ_SHA256 036b0ee118451539783ec7864148bb4106be42a2eb964df4e83e6703ec46f3d9)
#HARFBUZZ_ARGS="--without-glib --without-gobject --without-cairo --without-fontconfig --without-icu"
set(HARFBUZZ_OPTIONS -DHB_HAVE_GLIB=OFF -DHB_HAVE_ICU=OFF -DHB_BUILD_UTILS=OFF)
set(HARFBUZZ_PATCHES no-docs-tests no-features)

set(PIXMAN_VER 0.42.0)
set(PIXMAN_URL "https://cairographics.org/releases/pixman-${PIXMAN_VER}.tar.gz")
#set(PIXMAN_SHA256 )
#PIXMAN_ARGS="--disable-libpng --enable-dependency-tracking"
set(PIXMAN_PATCHES no-executables)

set(EXPAT_VER 2.4.9)
string(REPLACE "." "_" _EXPAT_VER ${EXPAT_VER})
set(EXPAT_URL "https://github.com/libexpat/libexpat/releases/download/R_${_EXPAT_VER}/expat-${EXPAT_VER}.tar.bz2")
set(EXPAT_SHA256 7f44d1469b110773a94b0d5abeeeffaef79f8bd6406b07e52394bcf48126437a)
unset(_EXPAT_VER)
set(EXPAT_OPTIONS -DEXPAT_BUILD_TOOLS=OFF -DEXPAT_BUILD_EXAMPLES=OFF -DEXPAT_BUILD_TESTS=OFF -DEXPAT_BUILD_DOCS=OFF -DEXPAT_SHARED_LIBS=OFF)
set(EXPAT_PATCHES low-entropy)

set(LIBOGG_VER 1.3.5)
set(LIBOGG_URL "https://downloads.xiph.org/releases/ogg/libogg-${LIBOGG_VER}.tar.xz")
set(LIBOGG_SHA256 c4d91be36fc8e54deae7575241e03f4211eb102afb3fc0775fbbc1b740016705)
set(LIBOGG_OPTIONS -DINSTALL_DOCS=OFF)

set(LIBVORBIS_VER 1.3.7)
set(LIBVORBIS_URL "https://downloads.xiph.org/releases/vorbis/libvorbis-${LIBVORBIS_VER}.tar.xz")
set(LIBVORBIS_SHA256 b33cc4934322bcbf6efcbacf49e3ca01aadbea4114ec9589d1b1e9d20f72954b)
set(LIBVORBIS_PATCHES remove-compiler-flag)

set(TREMOR_GITVER 7c30a66346199f3f09017a09567c6c8a3a0eedc8)
set(TREMOR_GITURL "https://gitlab.xiph.org/xiph/tremor.git")
set(TREMOR_PATCHES remove-macro)

set(MPG123_VER 1.30.2)
set(MPG123_URL "https://www.mpg123.de/download/mpg123-${MPG123_VER}.tar.bz2")
set(MPG123_SHA256 c7ea863756bb79daed7cba2942ad3b267a410f26d2dfbd9aaf84451ff28a05d7)
set(MPG123_OPTIONS -DBUILD_LIBOUT123=OFF -DBUILD_PROGRAMS=OFF)

set(LIBSNDFILE_VER 1.1.0)
set(LIBSNDFILE_URL "https://github.com/libsndfile/libsndfile/releases/download/${LIBSNDFILE_VER}/libsndfile-${LIBSNDFILE_VER}.tar.xz")
set(LIBSNDFILE_SHA256 0f98e101c0f7c850a71225fb5feaf33b106227b3d331333ddc9bacee190bcf41)
set(LIBSNDFILE_OPTIONS -DBUILD_PROGRAMS=OFF -DBUILD_EXAMPLES=OFF -DBUILD_TESTING=OFF -DENABLE_EXTERNAL_LIBS=OFF -DENABLE_MPEG=OFF -DENABLE_CPACK=OFF)

set(LIBXMPLITE_VER 4.5.0)
set(LIBXMPLITE_URL "https://github.com/libxmp/libxmp/releases/download/libxmp-${LIBXMPLITE_VER}/libxmp-lite-${LIBXMPLITE_VER}.tar.gz")
set(LIBXMPLITE_SHA256 19a019abd5a3ddf449cd20ca52cfe18970f6ab28abdffdd54cff563981a943bb)

set(SPEEXDSP_VER 1.2.1)
set(SPEEXDSP_URL "https://downloads.xiph.org/releases/speex/speexdsp-${SPEEXDSP_VER}.tar.gz")
#SPEEXDSP_ARGS="--disable-sse --disable-neon"

set(LIBSAMPLERATE_VER 0.2.2)
set(LIBSAMPLERATE_URL "https://github.com/libsndfile/libsamplerate/releases/download/${LIBSAMPLERATE_VER}/libsamplerate-${LIBSAMPLERATE_VER}.tar.xz")
set(LIBSAMPLERATE_SHA256 3258da280511d24b49d6b08615bbe824d0cacc9842b0e4caf11c52cf2b043893)
set(LIBSAMPLERATE_PATCHES no-examples)

set(WILDMIDI_VER 0.4.4)
set(WILDMIDI_URL "https://github.com/Mindwerks/wildmidi/archive/refs/tags/wildmidi-${WILDMIDI_VER}.tar.gz")
set(WILDMIDI_SHA256 6f267c8d331e9859906837e2c197093fddec31829d2ebf7b958cf6b7ae935430)
set(WILDMIDI_OPTIONS -DWANT_PLAYER=OFF -DWANT_STATIC=ON)

set(OPUS_VER 1.3.1)
set(OPUS_URL "https://downloads.xiph.org/releases/opus/opus-${OPUS_VER}.tar.gz")
set(OPUS_SHA256 65b58e1e25b2a114157014736a3d9dfeaad8d41be1c8179866f144a2fb44ff9d)
set(OPUS_OPTIONS -DOPUS_BUILD_PROGRAMS=OFF -DOPUS_DISABLE_INTRINSICS=ON)

set(OPUSFILE_VER 0.12)
set(OPUSFILE_URL "https://github.com/xiph/opusfile/releases/download/v${OPUSFILE_VER}/opusfile-${OPUSFILE_VER}.tar.gz")
set(OPUSFILE_SH256 118d8601c12dd6a44f52423e68ca9083cc9f2bfe72da7a8c1acb22a80ae3550b)
set(OPUSFILE_OPTIONS -DOP_DISABLE_HTTP=ON -DOP_DISABLE_EXAMPLES=OB -DOP_DISABLE_DOCS=ON)

set(FLUIDSYNTH_VER 2.2.9)
set(FLUIDSYNTH_URL "https://github.com/FluidSynth/fluidsynth/archive/refs/tags/v${FLUIDSYNTH_VER}.tar.gz")
set(FLUIDSYNTH_OPTIONS -DLIB_SUFFIX='')

set(FLUIDLITE_GITVER 7c150b021f8b7e7d4f624bbad644fd2f96e5826b)
set(FLUIDLITE_GITURL "https://github.com/divideconcept/FluidLite.git")
set(FLUIDLITE_OPTIONS -DFLUIDLITE_BUILD_STATIC=ON -DFLUIDLITE_BUILD_SHARED=OFF)

set(NLOHMANNJSON_VER 3.10.4)
set(NLOHMANNJSON_URL "https://github.com/nlohmann/json/archive/refs/tags/v${NLOHMANNJSON_VER}.tar.gz")
set(NLOHMANNJSON_OPTIONS -DJSON_BuildTests=OFF)

set(FMT_VER 9.1.0)
set(FMT_URL "https://github.com/fmtlib/fmt/releases/download/${FMT_VER}/fmt-${FMT_VER}.zip")
set(FMT_SHA256 cceb4cb9366e18a5742128cb3524ce5f50e88b476f1e54737a47ffdf4df4c996)
set(FMT_OPTIONS -DFMT_DOC=OFF -DFMT_TEST=OFF)

set(ICU_VER 69.1)
string(REPLACE "." "-" _ICU_VER ${ICU_VER})
set(ICU_URL https://github.com/unicode-org/icu/releases/download/release-${_ICU_VER}/icu4c-${_ICU_VER}-src.tgz)
#ICU_ARGS="--enable-strict=no --disable-tests --disable-samples \
#	--disable-dyload --disable-extras --disable-icuio \
#	--with-data-packaging=static --disable-layout --disable-layoutex"
set(ICU_PATCHES increase-small-buffer-size)

set(ICUDATA_URL https://ci.easyrpg.org/job/icudata/lastSuccessfulBuild/artifact/icudata.tar.gz)
#ICUDATA_FILES=icudt*.dat

set(SDL2_VER 2.24.0)
set(SDL2_URL "https://libsdl.org/release/SDL2-${SDL2_VER}.tar.gz")

# only needed for lmu2png tool
set(SDL2_IMAGE_VER 2.0.5)
set(SDL2_IMAGE_URL "https://www.libsdl.org/projects/SDL_image/release/SDL2_image-${SDL2_IMAGE_VER}.tar.gz")
#SDL2_IMAGE_ARGS="--disable-jpg --disable-png-shared --disable-tif --disable-webp"

set(LCF_VER 0.7.0)
set(LCF_URL "https://easyrpg.org/downloads/player/${LCF_VER}/liblcf-${LCF_VER}.tar.xz")
