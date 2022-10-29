
# everything earlier is ancient, devs should use latest tools
cmake_minimum_required(VERSION 3.18...3.24 FATAL_ERROR)

# helpers and definitions
list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")
include(functions)
include(libraries)

project(EasyRPG-buildscripts
	VERSION 2022.10.23
	HOMEPAGE_URL https://github.com/EasyRPG/buildscripts
	LANGUAGES NONE)

# global options
check_options()
check_tools()

# options for all platforms
option(BUILD_3DS "Build for Nintendo 3DS" OFF)
option(BUILD_ANDROID "Build for Android" OFF)
option(BUILD_EMSCRIPTEN "Build for the web" OFF)
option(BUILD_LINUX "Build for GNU/Linux (statically)" OFF)
option(BUILD_MACOS "Build for Apple macOS" OFF)
option(BUILD_SWITCH "Build for Nintendo Switch" OFF)
option(BUILD_PSVITA "Build for Sony PS Vita" OFF)
option(BUILD_WII "Build for Nintendo Wii" OFF)
option(BUILD_WINDOWS "Build for Microsoft Windows" OFF)
if(BUILD_3DS)
	add_subdirectory(3ds)
endif()
if(BUILD_ANDROID)
	add_subdirectory(android)
endif()
if(BUILD_EMSCRIPTEN)
	add_subdirectory(emscripten)
endif()
if(BUILD_LINUX)
	add_subdirectory(linux-static)
endif()
if(BUILD_MACOS)
	add_subdirectory(osx)
endif()
if(BUILD_SWITCH)
	add_subdirectory(switch)
endif()
if(BUILD_PSVITA)
	add_subdirectory(psvita)
endif()
if(BUILD_WII)
	add_subdirectory(wii)
endif()
if(BUILD_WINDOWS)
	add_subdirectory(windows)
endif()
