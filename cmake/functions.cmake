
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
		#	-DCMAKE_VERBOSE_MAKEFILE=ON
		INSTALL_COMMAND ${CMAKE_COMMAND} -E echo "Target Toolchain is at \"${CMAKE_CURRENT_SOURCE_DIR}\"."
		STEP_TARGETS configure build
	)

	# add convenience targets
	parse_libs(${CMAKE_CURRENT_SOURCE_DIR}/CMakeLists.txt LIB_TARGETS)
	#message(NOTICE "Adding convenience targets for: ${LIB_TARGETS}.")
	foreach(lib ${LIB_TARGETS})
		if(NOT ${lib} STREQUAL "lcf" OR (${lib} STREQUAL "lcf" AND ${ENABLE_LCF}))
			add_custom_target(cross-${lib} ${CMAKE_COMMAND} --build ${name} --target ${lib}
				COMMENT "Building ${lib} in cross environment..."
				VERBATIM
			)
			add_dependencies(cross-${lib} ${name}-configure)
		endif()
	endforeach()
endfunction()

####################

# general function, sets up environment, calls specific builder

function(build_lib name)
	cmake_parse_arguments(PARSE_ARGV 1 arg "CMAKE;AUTOTOOLS;VERBOSE;DEBUG" "SUBDIR;BOOTSTRAP" "PREFIX;OPTIONS;PATCHES")
	if(DEFINED arg_UNPARSED_ARGUMENTS)
		message(WARNING "build_lib: Passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
	endif()
	if(DEFINED arg_KEYWORDS_MISSING_VALUES)
		message(WARNING "build_lib: Missing arguments for: ${arg_KEYWORDS_MISSING_VALUES}")
	endif()

	# external debugging
	if(BUILD_LIB_VERBOSE)
		set(arg_VERBOSE TRUE)
	endif()

	# download type
	if(${arg_PREFIX}_URL)
		list(APPEND DOWNLOAD_OPTIONS URL ${${arg_PREFIX}_URL})
		# add our mirror
		string(REGEX REPLACE ".*/(.*)$" "\\1" file ${${arg_PREFIX}_URL})
		if(file)
			list(APPEND DOWNLOAD_OPTIONS "https://easyrpg.org/downloads/sources/${file}")
		else()
			message(WARNING "build_lib: Could not extract file name (${file}) from URL: ${${arg_PREFIX}_URL}, not using mirror")
		endif()

		if(${arg_PREFIX}_SHA256)
			list(APPEND DOWNLOAD_OPTIONS URL_HASH SHA256=${${arg_PREFIX}_SHA256})
		else()
			message(WARNING "build_lib: No hash for: ${name}, redownloading always")
		endif()
		list(APPEND DOWNLOAD_OPTIONS DOWNLOAD_NO_PROGRESS TRUE)
	elseif(${arg_PREFIX}_GITURL)
		list(APPEND DOWNLOAD_OPTIONS GIT_REPOSITORY ${${arg_PREFIX}_GITURL})
		if(${arg_PREFIX}_GITVER)
			list(APPEND DOWNLOAD_OPTIONS GIT_TAG ${${arg_PREFIX}_GITVER})
		else()
			message(WARNING "build_lib: No git version for: ${name}, using master")
		endif()
	endif()

	# build options
	set(GENERATOR_OPTIONS ${${arg_PREFIX}_OPTIONS} ${arg_OPTIONS})

	# patch options
	set(PATCHES ${${arg_PREFIX}_PATCHES} ${arg_PATCHES})
	list(LENGTH PATCHES NUM_PATCHES)
	if(NUM_PATCHES GREATER 0)
		#set(PATCH_OPTION PATCH)
	endif()

	# additional options
	if(arg_SUBDIR)
		# this is only needed for libmpg123 currently
		list(APPEND ADDITIONAL_OPTIONS SOURCE_SUBDIR ${arg_SUBDIR})
	endif()

	# configure needs autoreconf sometimes
	if(arg_BOOTSTRAP)
		set(BOOTSTRAP_OPTION BOOTSTRAP)
	endif()

	# directory setup
	set_directory_properties(PROPERTIES EP_PREFIX ".")
	list(APPEND ADDITIONAL_OPTIONS
		INSTALL_DIR ${CMAKE_CURRENT_SOURCE_DIR}
		LOG_DIR log
		DOWNLOAD_DIR download
	)

	if(NOT arg_VERBOSE)
		# enable file logging instead of terminal
		list(APPEND ADDITIONAL_OPTIONS
			LOG_DOWNLOAD TRUE
			LOG_UPDATE TRUE
			LOG_PATCH TRUE
			LOG_CONFIGURE TRUE
			LOG_BUILD TRUE
			LOG_INSTALL TRUE
			LOG_MERGED_STDOUTERR TRUE
			LOG_OUTPUT_ON_FAILURE TRUE
		)
		if(arg_CMAKE AND ${CMAKE_GENERATOR} STREQUAL "Unix Makefiles")
			list(APPEND GENERATOR_OPTIONS -DCMAKE_COLOR_MAKEFILE=OFF)
		endif()
	endif()

	if(arg_DEBUG)
		# generate immediate targets
		list(APPEND ADDITIONAL_OPTIONS STEP_TARGETS download update patch configure build install)
	endif()

	# sanitize
	list(LENGTH GENERATOR_OPTIONS NUM_GEN)
	if(NUM_GEN GREATER 0)
		set(GENERATOR_OPTION GENERATOR)
	endif()

	if(arg_CMAKE)
		build_lib_cmake(${name} DEBUG ${arg_DEBUG} VERBOSE ${arg_VERBOSE}
			DOWNLOAD ${DOWNLOAD_OPTIONS}
			${PATCH_OPTION} ${PATCH_OPTIONS}
			${GENERATOR_OPTION} ${GENERATOR_OPTIONS}
			ADDITIONAL ${ADDITIONAL_OPTIONS}
		)
	elseif(arg_AUTOTOOLS)
		build_lib_autotools(${name} DEBUG ${arg_DEBUG} VERBOSE ${arg_VERBOSE}
			DOWNLOAD ${DOWNLOAD_OPTIONS}
			${PATCH_OPTION} ${PATCH_OPTIONS}
			${BOOTSTRAP_OPTION} ${arg_BOOTSTRAP}
			${GENERATOR_OPTION} ${GENERATOR_OPTIONS}
			ADDITIONAL ${ADDITIONAL_OPTIONS}
		)
	else()
		message(FATAL_ERROR "build_lib: Build type not implemented.")
	endif()

endfunction()

# remove unneeded toolchain dirs after building

function(cleanup target)
	set(OPTIONS COMMENT "Deleting additional directories..."
		COMMAND ${CMAKE_COMMAND} -E rm -rf -- bin sbin share
		WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
		VERBATIM
	)

	if(${target} STREQUAL "ALL")
		add_custom_target(cleanup ALL ${OPTIONS})
		# ensure all libs are build
		parse_libs(${CMAKE_CURRENT_SOURCE_DIR}/CMakeLists.txt LIB_TARGETS)
		foreach(lib ${LIB_TARGETS})
			if(NOT ${lib} STREQUAL "lcf" OR (${lib} STREQUAL "lcf" AND ${ENABLE_LCF}))
				add_dependencies(cleanup ${lib})
			endif()
		endforeach()
	else()
		add_custom_command(TARGET ${target} POST_BUILD ${OPTIONS})
	endif()
endfunction()

# Parses a list of library targets to be consumed by parent build

function(parse_libs file var)
	set(regex "^[^\#]+build_lib ?\\(([^ ]+).*$")
	file(STRINGS ${file} build_libs REGEX ${regex})
	foreach(l ${build_libs})
		string(REGEX REPLACE ${regex} "\\1" lib ${l})
		list(APPEND libs ${lib})
	endforeach()
	set(${var} ${libs} PARENT_SCOPE)
endfunction()

####################

# helper functions/macros

macro(build_lib_setup_args)
	cmake_parse_arguments(PARSE_ARGV 1 "arg" "" "DEBUG;VERBOSE;GENERATOR_WRAPPER;BOOTSTRAP" "DOWNLOAD;PATCH;GENERATOR;ADDITIONAL")
	if(DEFINED arg_UNPARSED_ARGUMENTS)
		message(WARNING "build_lib_setup_args: passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
	endif()
	if(DEFINED arg_KEYWORDS_MISSING_VALUES)
		message(WARNING "build_lib_setup_args: missing arguments for: ${arg_KEYWORDS_MISSING_VALUES}")
	endif()
endmacro()

macro(build_lib_debug)
	if(arg_DEBUG)
		message(NOTICE "=== Config for ${name} ===")
		list(JOIN arg_DOWNLOAD "\n\t" _DOWNLOAD)
		message(NOTICE "Download Options:\n\t${_DOWNLOAD}")
		list(JOIN arg_PATCH "\n\t" _PATCH)
		message(NOTICE "Patch Options:\n\t${_PATCH}")
		list(JOIN arg_GENERATOR "\n\t" _GENERATOR)
		message(NOTICE "Generator Options:\n\t${_GENERATOR}")
		list(JOIN arg_ADDITIONAL "\n\t" _ADDITIONAL)
		message(NOTICE "Additional Options:\n\t${_ADDITIONAL}")
		message(NOTICE "")
	endif()
endmacro()

function(build_lib_cmake name)
	build_lib_setup_args()

	if(ENABLE_CCACHE)
		list(PREPEND arg_GENERATOR
			-DCMAKE_CXX_COMPILER_LAUNCHER=${CCACHE_EXECUTABLE}
			-DCMAKE_C_COMPILER_LAUNCHER=${CCACHE_EXECUTABLE}
		)
	endif()

	# needed for all cross builds besides emscripten
	if(CMAKE_TOOLCHAIN_FILE)
		list(PREPEND arg_GENERATOR -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE})
	endif()

	# common flags
	list(PREPEND arg_GENERATOR -DBUILD_SHARED_LIBS=OFF
		-DCMAKE_BUILD_TYPE=RelWithDebInfo
		-DCMAKE_INSTALL_PREFIX=${CMAKE_CURRENT_SOURCE_DIR}
	)

	if(arg_DEBUG AND ${CMAKE_GENERATOR} STREQUAL "Unix Makefiles")
		list(PREPEND arg_GENERATOR -DCMAKE_VERBOSE_MAKEFILE=ON)
	endif()

	# enble -fPIC
	if(CMAKE_POSITION_INDEPENDENT_CODE)
		list(PREPEND arg_GENERATOR -DCMAKE_POSITION_INDEPENDENT_CODE=ON)
	endif()

	build_lib_debug()

	ExternalProject_Add(${name}
		${arg_DOWNLOAD}
		${arg_PATCH}
		CMAKE_ARGS ${arg_GENERATOR}
		${arg_ADDITIONAL}
	)
endfunction()

function(build_lib_autotools name)
	build_lib_setup_args()

	cmake_host_system_information(RESULT Ncpu QUERY NUMBER_OF_PHYSICAL_CORES)
	message(STATUS "CMake ${CMAKE_VERSION} using ${Ncpu} threads")

	find_program(MAKE_EXECUTABLE NAMES gmake make mingw32-make REQUIRED)

	if(ENABLE_CCACHE)
		list(PREPEND arg_GENERATOR
			"CC=${CCACHE_EXECUTABLE} ${CMAKE_CXX_COMPILER}"
			"CXX=${CCACHE_EXECUTABLE} ${CMAKE_C_COMPILER}"
		)
	else()
		list(PREPEND arg_GENERATOR CC=${CMAKE_CXX_COMPILER} CXX=${CMAKE_C_COMPILER})
	endif()

	# common flags
	list(PREPEND arg_GENERATOR --enable-static --disable-shared
		--prefix=${CMAKE_CURRENT_SOURCE_DIR}
		--host=${AUTOTOOLS_TARGET_HOST}
		--disable-dependency-tracking
		--cache-file=${CMAKE_CURRENT_BINARY_DIR}/config.cache
	)

	if(arg_DEBUG AND ${CMAKE_GENERATOR} STREQUAL "Unix Makefiles")
		list(PREPEND arg_GENERATOR --disable-silent-rules)
	endif()

	# enble -fPIC
	#if(CMAKE_POSITION_INDEPENDENT_CODE)
	#	list(PREPEND arg_GENERATOR -DCMAKE_POSITION_INDEPENDENT_CODE=ON)
	#endif()

	build_lib_debug()

	ExternalProject_Add(${name}
		${arg_DOWNLOAD}
		${arg_PATCH}
		CONFIGURE_COMMAND <SOURCE_DIR>/configure ${arg_GENERATOR}
		BUILD_COMMAND ${MAKE_EXECUTABLE} -j${Ncpu}
		INSTALL_COMMAND ${MAKE_EXECUTABLE} -j${Ncpu} install
		${arg_ADDITIONAL}
	)

	if(arg_BOOTSTRAP)
		if(NOT arg_VERBOSE)
			# enable file logging instead of terminal
			set(LOG_OPTION LOG TRUE)
		endif()

		ExternalProject_Add_Step(${name}
			bootstrap
			COMMAND <SOURCE_DIR>/${arg_BOOTSTRAP}
			DEPENDEES download
			DEPENDERS configure
			WORKING_DIRECTORY <BINARY_DIR>
			${LOG_OPTION}
		)
	endif()

endfunction()
