
function(check_dkp_env platform) # BASE, 3DS, SWITCH, WII
	if(platform STREQUAL BASE)
		if(NOT DEFINED ENV{DEVKITPRO})
			message(FATAL_ERROR "Did not find $DEVKITPRO environment variable!")
		endif()
	elseif(platform STREQUAL 3DS)
		if(NOT DEFINED ENV{DEVKITARM})
			message(WARNING "Did not find $DEVKITARM environment variable!")
		endif()

		set(libpath $ENV{DEVKITPRO}/libctru/lib)
		find_library(LIB_CTRU ctru PATHS ${libpath} REQUIRED)
		find_library(LIB_C3D citro3d PATHS ${libpath} REQUIRED)
		find_library(LIB_C2D citro2d PATHS ${libpath} REQUIRED)
		# tools are checked by toolchain file
	else()
		message(FATAL_ERROR "Unknown DKP platform!")
	endif()
endfunction()
