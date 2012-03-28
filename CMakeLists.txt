cmake_minimum_required(VERSION 2.8)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -pedantic -Wall -DHAVE_INTTYPES_H -std=c++0x")

find_package(PkgConfig)

pkg_check_modules(THRIFT REQUIRED thrift>=0.8.0)

set(GEN_THRIFT GenerateThrift)

set(THRIFT_FILE ${CMAKE_CURRENT_SOURCE_DIR}/src/main/thrift/sessionSpec.thrift)

# TODO this should depend (and optionally execute) for all thrift files
add_custom_command(
	OUTPUT		${GEN_THRIFT}

	DEPENDS		${THRIFT_FILE}
	COMMENT		"thrift2cpp"

	COMMAND		thrift
	ARGS		-r --gen cpp -o ${CMAKE_BINARY_DIR}
			${THRIFT_FILE}

	# Next command forces cmake to re-create Makefiles this way GLOB will
	# work and get all generated files
	COMMAND		rm
	ARGS		${CMAKE_BINARY_DIR}/CMakeFiles/Makefile.cmake

	COMMAND		touch
	ARGS		${GEN_THRIFT}

	COMMAND		make
)

FILE(GLOB ALL_CPP_SRCS ${CMAKE_BINARY_DIR}/gen-cpp/*.cpp)

SET(DUMMY_FILE ${CMAKE_BINARY_DIR}/dummy.cpp)
file(WRITE ${DUMMY_FILE})

add_library(mediaspec ${ALL_CPP_SRCS} ${DUMMY_FILE} ${GEN_THRIFT})

include_directories(mediaspec ${THRIFT_INCLUDE_DIRS})
target_link_libraries(mediaspec ${THRIFT_LIBRARIES})

add_dependencies(mediaspec GenerateThrift)

# TODO generate rules to install library and generated headers
