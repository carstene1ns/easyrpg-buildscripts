
# everything earlier is ancient, devs should use latest tools
cmake_minimum_required(VERSION 3.18...3.24 FATAL_ERROR)

# helpers and definitions
list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/../cmake")
include(functions)
include(libraries)

project(EasyRPG-libs-linux-static LANGUAGES NONE)

check_options()
check_tools()

message(NOTICE "Building Linux-static libraries...")

# debugging
set(BUILD_LIB_VERBOSE 1)

# TODO: -Os -ffunction-sections -fdata-sections
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

build_lib(z CMAKE PREFIX "ZLIB")
build_lib(png CMAKE PREFIX "LIBPNG")
build_lib(freetype-stage1 CMAKE PREFIX "FREETYPE" OPTIONS -DFT_DISABLE_HARFBUZZ=TRUE)
build_lib(harfbuzz CMAKE PREFIX "HARFBUZZ")
build_lib(freetype-stage2 CMAKE PREFIX "FREETYPE" OPTIONS -DFT_REQUIRE_HARFBUZZ=TRUE)
# pixman
build_lib(expat CMAKE PREFIX "EXPAT")
build_lib(ogg CMAKE PREFIX "LIBOGG")
build_lib(vorbis CMAKE PREFIX "LIBVORBIS")
build_lib(mpg123 CMAKE PREFIX "MPG123" SUBDIR "ports/cmake")
build_lib(sndfile CMAKE PREFIX "LIBSNDFILE")
#build_lib(xmp-lite CMAKE PREFIX "LIBXMPLITE")
#build_lib(speexdsp CMAKE PREFIX "SPEEXDSP")
build_lib(wildmidi CMAKE PREFIX "WILDMIDI")
#build_lib(opus CMAKE PREFIX "OPUS")
#build_lib(opusfile CMAKE PREFIX "OPUSFILE")
build_lib(fluidsynth CMAKE PREFIX "FLUIDSYNTH")
build_lib(json CMAKE PREFIX "NLOHMANNJSON")
build_lib(fmt CMAKE PREFIX "FMT")
# icu
if(ENABLE_LIBLCF)
	build_lib(lcf CMAKE PREFIX "LCF")
endif()

build_lib(sdl2 CMAKE PREFIX "SDL2" OPTIONS -DPULSEAUDIO_CFLAGS=-Ixxxdir -DPULSEAUDIO_LIBS=-lxxxlib)
build_lib(sdl2_image CMAKE PREFIX "SDL2_IMAGE")

cleanup(ALL)
