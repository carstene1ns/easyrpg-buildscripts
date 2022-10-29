
function(check_tools)

	find_package(Git REQUIRED)

	check_ccache(VERBOSE)

endfunction()

macro(check_ccache)
	cmake_parse_arguments(arg "VERBOSE" "" "" ${ARGN})

	if(${ENABLE_CCACHE})
		find_program(CCACHE_EXECUTABLE ccache)
		if(CCACHE_EXECUTABLE)
			if(arg_VERBOSE)
				message(STATUS "Using ${CCACHE_EXECUTABLE} as compiler launcher to speed up builds.")
			endif()
			set(CMAKE_C_COMPILER_LAUNCHER ${CCACHE_EXECUTABLE})
			set(CMAKE_CXX_COMPILER_LAUNCHER ${CCACHE_EXECUTABLE})
		endif()
	endif()
	if(NOT CCACHE_EXECUTABLE AND arg_VERBOSE)
		message(STATUS "Not using ccache to speed up builds.")
	endif()
endmacro()

macro(check_options)
	option(ENABLE_CCACHE "Use ccache to speed up rebuilds" ON)
	option(ENABLE_LCF "Build liblcf as part of toolchain" OFF)
	option(BUILD_LIB_VERBOSE "Log to terminal instead of logfiles" OFF)
endmacro()

####################

include(ExternalProject)

function(run_with_toolchain platform toolchain_file)
	set(name ${platform}-cross)
	set(output_dir ${CMAKE_BINARY_DIR}/${name})
	ExternalProject_Add(${name}
		PREFIX ${output_dir}
		SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}
		BINARY_DIR ${output_dir}
		CMAKE_ARGS 
			-DCMAKE_TOOLCHAIN_FILE=${toolchain_file}
			-B${output_dir}
			-DENABLE_CCACHE=${ENABLE_CCACHE}
			-DENABLE_LIBLCF=${ENABLE_LCF}
			-DBUILD_LIB_VERBOSE=${BUILD_LIB_VERBOSE}
			-DCMAKE_VERBOSE_MAKEFILE=ON
		INSTALL_COMMAND ${CMAKE_COMMAND} -E echo "Target Toolchain is at \"${CMAKE_CURRENT_SOURCE_DIR}\"."
	)
endfunction()

####################

# general function, sets up environment, calls specific builder

function(build_lib name)
	cmake_parse_arguments(PARSE_ARGV 1 arg "CMAKE;AUTOTOOLS;VERBOSE;DEBUG" "SUBDIR" "PREFIX;OPTIONS;PATCHES")
	if(DEFINED arg_UNPARSED_ARGUMENTS)
		message(WARNING "build_lib: passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
	endif()
	if(DEFINED arg_KEYWORDS_MISSING_VALUES)
		message(WARNING "build_lib: missing arguments for: ${arg_KEYWORDS_MISSING_VALUES}")
	endif()

	# external debugging
	if(BUILD_LIB_VERBOSE)
		set(arg_VERBOSE TRUE)
	endif()

	# download type
	if(${arg_PREFIX}_URL)
		list(APPEND DOWNLOAD_OPTIONS URL ${${arg_PREFIX}_URL})
		if(${arg_PREFIX}_SHA256)
			list(APPEND DOWNLOAD_OPTIONS URL_HASH SHA256=${${arg_PREFIX}_SHA256})
		else()
			message(WARNING "No hash for: ${name}, redownloading always")
		endif()
		list(APPEND DOWNLOAD_OPTIONS DOWNLOAD_NO_PROGRESS TRUE)
	elseif(${arg_PREFIX}_GITURL)
		list(APPEND DOWNLOAD_OPTIONS GIT_REPOSITORY ${${arg_PREFIX}_GITURL})
		if(${arg_PREFIX}_GITVER)
			list(APPEND DOWNLOAD_OPTIONS GIT_TAG ${${arg_PREFIX}_GITVER})
		else()
			message(WARNING "No git version for: ${name}, using master")
		endif()
	endif()

	# build options
	set(GENERATOR_OPTIONS ${${arg_PREFIX}_OPTIONS} ${arg_OPTIONS})

	# patch options
	set(PATCHES ${${arg_PREFIX}_PATCHES} ${arg_PATCHES})
	list(LENGTH PATCHES NUM_PATCHES)
	if(NUM_PATCHES GREATER 0)
		set(PATCH_OPTION PATCH)
	endif()

	# additional options
	# this is only needed for libmpg123 currently
	if(arg_SUBDIR)
		list(APPEND ADDITIONAL_OPTIONS SOURCE_SUBDIR ${arg_SUBDIR})
	endif()

	# directory setup
	set_directory_properties(PROPERTIES EP_BASE libraries)
	list(APPEND ADDITIONAL_OPTIONS INSTALL_DIR ${CMAKE_CURRENT_SOURCE_DIR} LOG_DIR log)
	if(NOT arg_VERBOSE)
		# enable logging instead of terminal
		list(APPEND ADDITIONAL_OPTIONS LOG_DOWNLOAD TRUE LOG_UPDATE TRUE LOG_PATCH TRUE LOG_CONFIGURE TRUE LOG_BUILD TRUE LOG_INSTALL TRUE LOG_MERGED_STDOUTERR TRUE LOG_OUTPUT_ON_FAILURE TRUE)
		list(APPEND GENERATOR_OPTIONS -DCMAKE_COLOR_MAKEFILE=OFF)
	endif()

	if(arg_CMAKE)
		if(ENABLE_CCACHE)
			list(PREPEND GENERATOR_OPTIONS -DCMAKE_CXX_COMPILER_LAUNCHER=${CMAKE_CXX_COMPILER_LAUNCHER} -DCMAKE_C_COMPILER_LAUNCHER=${CMAKE_C_COMPILER_LAUNCHER})
		endif()

		# needed for all cross builds besides emscripten
		if(CMAKE_TOOLCHAIN_FILE)
			list(PREPEND GENERATOR_OPTIONS -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE})
		endif()

	elseif(arg_AUTOTOOLS)
		message(WARNING "build_lib: autotools not implemented.")
	else()
		message(FATAL_ERROR "build_lib: build type not implemented.")
	endif()

	# debug
	if(arg_DEBUG)
		message(NOTICE "Config for ${name}:")
		list(JOIN DOWNLOAD_OPTIONS "\n\t" _DOWNLOAD_OPTIONS)
		message(NOTICE "[Download Options]\n${_DOWNLOAD_OPTIONS}")
		list(JOIN PATCH_OPTIONS "\n\t" _PATCH_OPTIONS)
		message(NOTICE "[Patch Options]\n${_PATCH_OPTIONS}")
		list(JOIN GENERATOR_OPTIONS "\n" _GENERATOR_OPTIONS)
		message(NOTICE "[Generator Options]\n${_GENERATOR_OPTIONS}")
		list(JOIN ADDITIONAL_OPTIONS "\n\t" _ADDITIONAL_OPTIONS)
		message(NOTICE "[Additional Options]\n${_ADDITIONAL_OPTIONS}")
		message(NOTICE "=========================================")
	endif()

	if(arg_CMAKE)
		build_lib_cmake(${name}
			DOWNLOAD ${DOWNLOAD_OPTIONS}
			${PATCH_OPTION} ${PATCH_OPTIONS}
			GENERATOR ${GENERATOR_OPTIONS}
			ADDITIONAL ${ADDITIONAL_OPTIONS}
		)
	elseif(arg_AUTOTOOLS)
		# TODO
	endif()
endfunction()

# 

function(cleanup subdir)
	add_custom_command(TARGET ${subdir}-cross POST_BUILD
		COMMENT "Deleting additional directories..."
		COMMAND ${CMAKE_COMMAND} -E rm -rf -- bin sbin share
		WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
		VERBATIM
	)
endfunction()

# internal functions/macros

macro(build_lib_setup_args)
	cmake_parse_arguments(PARSE_ARGV 1 "arg" "" "GENERATOR_WRAPPER" "DOWNLOAD;PATCH;GENERATOR;ADDITIONAL")
	if(DEFINED arg_UNPARSED_ARGUMENTS)
		message(WARNING "build_lib_setup_args: passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
	endif()
	if(DEFINED arg_KEYWORDS_MISSING_VALUES)
		message(WARNING "build_lib_setup_args: missing arguments for: ${arg_KEYWORDS_MISSING_VALUES}")
	endif()
endmacro()

function(build_lib_cmake name)
	build_lib_setup_args()

	ExternalProject_Add(${name}
		${arg_DOWNLOAD}
		${arg_PATCH}
		CMAKE_ARGS
			-DBUILD_SHARED_LIBS=OFF
			-DCMAKE_BUILD_TYPE=RelWithDebInfo
			-DCMAKE_INSTALL_PREFIX=${CMAKE_CURRENT_SOURCE_DIR}
			-DCMAKE_VERBOSE_MAKEFILE=ON
			${arg_GENERATOR}
		${arg_ADDITIONAL}
	)
endfunction()

function(build_lib_autotools name)
	build_lib_setup_args()

endfunction()
