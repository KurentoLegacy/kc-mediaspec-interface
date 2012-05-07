cmake_minimum_required(VERSION 2.8)

# TODO: Check if HAVE_INIT_TYPES_H has to be added (not in all systems)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -pedantic -Wall -Werror -DHAVE_INTTYPES_H -std=c++0x")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -pedantic -Wall -std=c99")

find_package(PkgConfig)

pkg_check_modules(THRIFT REQUIRED thrift>=0.8.0)
pkg_check_modules(THRIFTC REQUIRED thrift_c_glib>=0.8.0)

if(EXISTS "${CMAKE_SOURCE_DIR}/.git")
	execute_process(COMMAND git describe --abbrev=6 --tags --dirty --always
			OUTPUT_VARIABLE MEDIASPEC_VERSION
			OUTPUT_STRIP_TRAILING_WHITESPACE)
	string(REGEX REPLACE "^kc-mediaspec-interface-(.*)" "\\1" MEDIASPEC_VERSION ${MEDIASPEC_VERSION})
else(EXISTS "${CMAKE_SOURCE_DIR}/.git")
	set(MEDIASPEC_MAJOR_VERSION 1)
	set(MEDIASPEC_MINOR_VERSION 0)
	set(MEDIASPEC_PATCH_VERSION 1-dev)
	set(MEDIASPEC_VERSION
		${MEDIASPEC_MAJOR_VERSION}.${MEDIASPEC_MINOR_VERSION}.${MEDIASPEC_PATCH_VERSION})
endif(EXISTS "${CMAKE_SOURCE_DIR}/.git")

CONFIGURE_FILE(${CMAKE_CURRENT_SOURCE_DIR}/mediaspec_config.h.cmake ${CMAKE_CURRENT_BINARY_DIR}/mediaspec_config.h)

set(GEN_H_FILES mediaspec_config.h)
set(GEN_HPP_FILES mediaspec_config.h)

set(THRIFT_FILES_DIR ${CMAKE_CURRENT_SOURCE_DIR}/src/main/thrift)
set(GEN_CPP_FILES_DIR ${CMAKE_BINARY_DIR}/gen-cpp)
FILE(MAKE_DIRECTORY ${GEN_CPP_FILES_DIR})

set(GEN_C_FILES_DIR ${CMAKE_BINARY_DIR}/gen-c_glib)
FILE(MAKE_DIRECTORY ${GEN_C_FILES_DIR})

FILE(GLOB THRIFT_FILES ${THRIFT_FILES_DIR}/*.thrift)

find_program(THRIFT_EXEC thrift)

IF(NOT EXISTS ${THRIFT_EXEC})
	MESSAGE(FATAL_ERROR "Thrift not foud")
ENDIF(NOT EXISTS ${THRIFT_EXEC})

MESSAGE(STATUS "Trift found: ${THRIFT_EXEC}")

function(get_base_name thrift_file out_base_name)
	STRING(REGEX REPLACE "[/]+(([^/]+)[/]+)+(.*).thrift\$" "\\3" base_name "${thrift_file}")
	SET(${out_base_name} ${base_name} PARENT_SCOPE)

	if (NOT ${ARGV2} EQUAL "")
		STRING(REGEX REPLACE "([a-z0-9]+)([A-Z])" "\\1_\\2" underscore "${base_name}")
# 		#Proccess the base name in underscore case
		STRING(TOLOWER ${underscore} underscore)

		SET(${ARGV2} "${underscore}" PARENT_SCOPE)
	endif(NOT ${ARGV2} EQUAL "")
endfunction(get_base_name)

FOREACH(THRIFT_FILE ${THRIFT_FILES})
	SET(CUR_GEN_CPP_FILES "")
	get_base_name(${THRIFT_FILE} BASE_NAME UNDERSCORE)
	MESSAGE(STATUS "Processing thrift file: ${BASE_NAME}.thrift")

	SET(CPP_FILE "${GEN_CPP_FILES_DIR}/${BASE_NAME}_types.cpp")
	SET(CUR_GEN_CPP_FILES ${CUR_GEN_CPP_FILES} ${CPP_FILE})
	SET(CPP_FILE "${GEN_CPP_FILES_DIR}/${BASE_NAME}_constants.cpp")
	SET(CUR_GEN_CPP_FILES ${CUR_GEN_CPP_FILES} "${CPP_FILE}")

	SET(HPP_FILE "${GEN_CPP_FILES_DIR}/${BASE_NAME}_types.h")
	SET(GEN_HPP_FILES ${GEN_HPP_FILES} ${HPP_FILE})
	SET(HPP_FILE "${GEN_CPP_FILES_DIR}/${BASE_NAME}_constants.h")
	SET(GEN_HPP_FILES ${GEN_HPP_FILES} "${HPP_FILE}")

	SET(GEN_CPP_FILES ${GEN_CPP_FILES} ${CUR_GEN_CPP_FILES})

	FOREACH(CPP_FILE ${CUR_GEN_CPP_FILES})
		ADD_CUSTOM_COMMAND(
			COMMENT		"Generating c++ source from: ${BASE_NAME}.thrift"

			OUTPUT		"${CPP_FILE}"

			DEPENDS		"${THRIFT_FILE}"

			COMMAND		${THRIFT_EXEC}
			ARGS		--gen cpp -r -out "${GEN_CPP_FILES_DIR}" "${THRIFT_FILE}"
		)
	ENDFOREACH(CPP_FILE)

	SET(C_FILE "${GEN_C_FILES_DIR}/kms_${UNDERSCORE}_types.c")
	SET(GEN_C_FILES ${GEN_C_FILES} ${C_FILE})

	SET(H_FILE "${GEN_C_FILES_DIR}/kms_${UNDERSCORE}_types.h")
	SET(GEN_H_FILES ${GEN_H_FILES} ${H_FILE})

	ADD_CUSTOM_COMMAND(
		COMMENT		"Generating c_glib source from: ${BASE_NAME}.thrift"

		OUTPUT		"${C_FILE}"

		DEPENDS		"${THRIFT_FILE}"

		COMMAND		${THRIFT_EXEC}
		ARGS		--gen c_glib -r -out "${GEN_C_FILES_DIR}" "${THRIFT_FILE}"
	)
ENDFOREACH(THRIFT_FILE)

SET(MEDIASPEC_INCLUDES "${GEN_HPP_FILES}" "${THRIFT_FILES}")

add_library(mediaspec ${GEN_CPP_FILES})

include_directories(mediaspec ${THRIFT_INCLUDE_DIRS})
target_link_libraries(mediaspec ${THRIFT_LIBRARIES})

set_target_properties(mediaspec PROPERTIES
	PUBLIC_HEADER	"${MEDIASPEC_INCLUDES}"
)

INSTALL(TARGETS mediaspec
		ARCHIVE DESTINATION lib
		PUBLIC_HEADER DESTINATION include
)

SET(GMEDIASPEC_INCLUDES "${GEN_H_FILES}" "${THRIFT_FILES}")

add_library(gmediaspec ${GEN_C_FILES})

include_directories(gmediaspec ${THRIFTC_INCLUDE_DIRS})
target_link_libraries(gmediaspec ${THRIFTC_LIBRARIES})

set_target_properties(gmediaspec PROPERTIES
	PUBLIC_HEADER	"${GMEDIASPEC_INCLUDES}"
)

INSTALL(TARGETS gmediaspec
		ARCHIVE DESTINATION lib
		PUBLIC_HEADER DESTINATION include
)
