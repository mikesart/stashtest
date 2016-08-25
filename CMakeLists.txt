# CMakeLists.txt for stashtest
# 
# While this can build the linux version it is not recommended use the 
# project's native makefiles
#
cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
project("stashtest")

# bring in useful cmake macros
# https://github.com/onqtam/ucm
include("ucm.cmake")

ucm_set_runtime(STATIC)
ucm_print_flags()

# Same flags as the Linux Makefile
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -DDEBUG")
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -DNDEBUG")

if(CMAKE_COMPILER_IS_GNUCC OR APPLE)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
endif()

# Library location configuration everything relative to the CMakeLists.txt
set(LIBGIT2_DIR ${CMAKE_CURRENT_LIST_DIR}/../libgit2)
set(LIBGIT2_INCLUDE ${LIBGIT2_DIR}/include)
set(LIBGIT2_BIN ${LIBGIT2_DIR}/build)

# for MSVC kill off all the CRT security warnings everywhere
# kill warning 4351 everywhere it's a c++11 feature that the warning is for old code
if(MSVC)
ADD_DEFINITIONS (/D _CRT_SECURE_NO_WARNINGS /wd4351)
endif(MSVC)

if (WIN32)
	LINK_LIBRARIES(shlwapi winhttp rpcrt4 crypt32 ole32)
endif()

if (UNIX)
  LINK_LIBRARIES(m dl pthread stdc++)
endif()

if (APPLE)
  LINK_LIBRARIES("-framework Foundation" "-framework Cocoa" "-framework CoreAudio" "-framework OpenGl" "-framework ApplicationServices")
endif()

# Main source list
set(SRC_LIST
	../gitwin.cpp
	)


if (APPLE)
set(LIBRARY_LIST
  ${LIBGIT2_BIN}/libgit2.dylib
  )
endif()

if (UNIX AND NOT APPLE)
set(LIBRARY_LIST
  ${LIBGIT2_BIN}/libgit2.so
  )
endif()

if (WIN32)
  set(LIBRARY_LIST
	${LIBGIT2_BIN}/git2.lib
	)

  set(WIN_LINK_FLAGS "/LTCG /NODEFAULTLIB:MSVCRT")
  string(REPLACE "/INCREMENTAL" "" CMAKE_EXE_LINKER_FLAGS_DEBUG "${CMAKE_EXE_LINKER_FLAGS_DEBUG}")
  string(REPLACE "/INCREMENTAL" "" CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO "${CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO}")
  set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${WIN_LINK_FLAGS}")

endif()

include_directories(
  ${LIBGIT2_INCLUDE}
  ${CMAKE_CURRENT_LIST_DIR}/src
  )

add_executable(
  ${PROJECT_NAME} WIN32
  ${SRC_LIST}
  )

target_link_libraries(
  ${PROJECT_NAME}
  ${LIBRARY_LIST}
)


