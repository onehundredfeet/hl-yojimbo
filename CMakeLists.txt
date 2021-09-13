cmake_minimum_required(VERSION 3.10)

add_library(yojimbo.hdll SHARED
#Input C++ files go here
#${YOJIMBO_SRC_DIR}/INPUT FILES GO HERE.cpp

src/yojimbo.cpp
)

set_target_properties(yojimbo.hdll
PROPERTIES
PREFIX ""
OUTPUT_NAME yojimbo
SUFFIX .hdll
)

cmake_policy(SET CMP0015 NEW)

target_include_directories(yojimbo.hdll
PRIVATE
${YOJIMBO_SRC_DIR}
${HL_INCLUDE_DIR}
)

link_directories(yojimbo.hdll
${HL_LIB_DIR}
)

find_library(LIBHL NAMES hl 
             HINTS ${HL_LIB_DIR} )

target_link_libraries(yojimbo.hdll
${LIBHL}
)


if (UNIX)
    # Some special flags are needed for GNU GCC compiler
    SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++17 -fPIC  -O3  -fpermissive")
    #not sure why the ${HL_LIB_DIR} is necessary given the above.
    SET(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_MODULE_LINKER_FLAGS} -shared  ")
endif (UNIX)

install(TARGETS yojimbo.hdll DESTINATION ${HDLL_DESTINATION})
