cmake_minimum_required(VERSION 2.8)

# TODO: Check if HAVE_INIT_TYPES_H has to be added (not in all systems)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -pedantic -Wall -DHAVE_INTTYPES_H -std=c++0x")

find_package(PkgConfig)
find_package(EXPORT)

pkg_check_modules(THRIFT REQUIRED thrift>=0.8.0)

set(THRIFT_FILES_DIR ${CMAKE_CURRENT_SOURCE_DIR}/src/main/thrift)
set(GEN_FILES_DIR ${CMAKE_BINARY_DIR}/gen-cpp)
FILE(MAKE_DIRECTORY ${GEN_FILES_DIR})

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
		#Proccess the base name in camel case
		STRING(SUBSTRING ${base_name} 0 1 head)
		STRING(SUBSTRING ${base_name} 1 -1 tail)
		STRING(TOUPPER ${head} upper_head)

		SET(${ARGV2} "${upper_head}${tail}" PARENT_SCOPE)
	endif(NOT ${ARGV2} EQUAL "")
endfunction(get_base_name)

FOREACH(THRIFT_FILE ${THRIFT_FILES})
	SET(CUR_GEN_CPP_FILES "")
	get_base_name(${THRIFT_FILE} BASE_NAME)
	MESSAGE(STATUS "Processing thrift file: ${BASE_NAME}.thrift")

	SET(CPP_FILE "${GEN_FILES_DIR}/${BASE_NAME}_types.cpp")
	SET(CUR_GEN_CPP_FILES ${CUR_GEN_CPP_FILES} ${CPP_FILE})
	SET(CPP_FILE "${GEN_FILES_DIR}/${BASE_NAME}_constants.cpp")
	SET(CUR_GEN_CPP_FILES ${CUR_GEN_CPP_FILES} "${CPP_FILE}")

	SET(H_FILE "${GEN_FILES_DIR}/${BASE_NAME}_types.h")
	SET(GEN_H_FILES ${GEN_H_FILES} ${H_FILE})
	SET(H_FILE "${GEN_FILES_DIR}/${BASE_NAME}_constants.h")
	SET(GEN_H_FILES ${GEN_H_FILES} "${H_FILE}")

	SET(GEN_CPP_FILES ${GEN_CPP_FILES} ${CUR_GEN_CPP_FILES})

	FOREACH(CPP_FILE ${CUR_GEN_CPP_FILES})
		ADD_CUSTOM_COMMAND(
			COMMENT		"Generating source from: ${BASE_NAME}.thrift"

			OUTPUT		"${CPP_FILE}"

			DEPENDS		"${THRIFT_FILE}"

			COMMAND		${THRIFT_EXEC}
			ARGS		--gen cpp -out "${GEN_FILES_DIR}" "${THRIFT_FILE}"
		)
	ENDFOREACH(CPP_FILE)
ENDFOREACH(THRIFT_FILE)

SET(ALL_INCLUDES "${GEN_H_FILES}" "${THRIFT_FILES}")

add_library(mediaspec ${GEN_CPP_FILES})

include_directories(mediaspec ${THRIFT_INCLUDE_DIRS})
target_link_libraries(mediaspec ${THRIFT_LIBRARIES})

set_target_properties(mediaspec PROPERTIES
	PUBLIC_HEADER	"${ALL_INCLUDES}"
)

EXPORT(
	TARGETS mediaspec
	FILE mediaspec-build.cmake
)

INSTALL(TARGETS mediaspec EXPORT mediaspec-install
		ARCHIVE DESTINATION lib
		PUBLIC_HEADER DESTINATION include
)

INSTALL(
	EXPORT mediaspec-install
	DESTINATION lib
	FILE mediaspec-install.cmake
	#PREFIX mediaspec-1.0.0-
)
