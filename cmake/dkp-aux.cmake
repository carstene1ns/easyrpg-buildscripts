
function(check_dkp_env platform) # BASE, 3DS, SWITCH, WII
	if(platform STREQUAL BASE)
		if(NOT DEFINED ENV{DEVKITPRO})
			message(FATAL_ERROR "Did not find $DEVKITPRO environment variable!")
		endif()
	elseif(platform STREQUAL 3DS)
		if(NOT DEFINED ENV{DEVKITARM})
			message(FATAL_ERROR "Did not find $DEVKITARM environment variable!")
		endif()
		if(NOT EXISTS $ENV{DEVKITARM})
			message(FATAL_ERROR "Did not find devkitARM!")
		endif()

		set(libpath $ENV{DEVKITPRO}/libctru/lib)
		find_library(LIB_CTRU ctru PATHS ${libpath} REQUIRED)
		find_library(LIB_C3D citro3d PATHS ${libpath} REQUIRED)
		find_library(LIB_C2D citro2d PATHS ${libpath} REQUIRED)
		# tools are checked by toolchain file
	elseif(platform STREQUAL SWITCH)
		if(NOT EXISTS $ENV{DEVKITPRO}/devkitA64)
			message(FATAL_ERROR "Did not find devkitA64!")
		endif()

		find_library(LIB_NX nx PATHS $ENV{DEVKITPRO}/libnx/lib REQUIRED)
		# tools are checked by toolchain file
	else()
		message(FATAL_ERROR "Unknown DKP platform!")
	endif()
endfunction()
