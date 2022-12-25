
# everything earlier is ancient, devs should use latest tools
cmake_minimum_required(VERSION 3.18...3.24 FATAL_ERROR)

# helpers and definitions
list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/../cmake")
include(functions)
include(libraries)
include(dkp-aux)

project(EasyRPG-libs-3ds LANGUAGES NONE)

if(NOT CMAKE_TOOLCHAIN_FILE)
	# first iteration

	message(NOTICE "Preparing 3DS cross toolchain...")

	check_dkp_env(BASE)
	check_options()
	check_tools()
	run_with_toolchain(3ds $ENV{DEVKITPRO}/cmake/3DS.cmake)
	cleanup(3ds-cross)
else()
	# second iteration

	message(NOTICE "Building 3DS cross toolchain...")

	check_dkp_env(3DS)
	check_ccache()

	# local overrides
	include(libraries.cmake) # icu 59.2

	# debugging
	set(BUILD_LIB_VERBOSE 1)
	set(AUTOTOOLS_TARGET_HOST arm-none-eabi)

	#build_lib(z CMAKE PREFIX "ZLIB")
	#build_lib(png CMAKE PREFIX "LIBPNG")
	#build_lib(freetype-stage1 CMAKE PREFIX "FREETYPE" OPTIONS -DFT_DISABLE_HARFBUZZ=TRUE)
	#build_lib(harfbuzz CMAKE PREFIX "HARFBUZZ")
	#build_lib(freetype-stage2 CMAKE PREFIX "FREETYPE" OPTIONS -DFT_REQUIRE_HARFBUZZ=TRUE)
	build_lib(pixman DEBUG AUTOTOOLS PREFIX "PIXMAN")
	#build_lib(expat CMAKE PREFIX "EXPAT")
	#build_lib(ogg CMAKE PREFIX "LIBOGG")
	build_lib(tremor DEBUG AUTOTOOLS PREFIX "TREMOR" BOOTSTRAP "autogen.sh")
	#build_lib(mpg123 CMAKE PREFIX "MPG123" SUBDIR "ports/cmake")
	#build_lib(sndfile CMAKE PREFIX "LIBSNDFILE")
	#build_lib(xmp-lite CMAKE PREFIX "LIBXMPLITE")
	build_lib(speexdsp DEBUG AUTOTOOLS PREFIX "SPEEXDSP")
	#build_lib(wildmidi CMAKE PREFIX "WILDMIDI")
	#build_lib(opus CMAKE PREFIX "OPUS")
	#build_lib(opusfile CMAKE PREFIX "OPUSFILE")
	#build_lib(fluidlite CMAKE PREFIX "FLUIDLITE")
	#build_lib(fmt CMAKE PREFIX "FMT")
	# icu
	if(ENABLE_LIBLCF)
		#build_lib(lcf CMAKE PREFIX "LCF")
	endif()

endif()
