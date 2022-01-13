cmake_minimum_required(VERSION 3.10)
project(yojimbo)



if (NOT YOJIMBO_ROOT) 
set(YOJIMBO_ROOT "ext/yojimbo")
endif()

if (NOT YOJIMBO_SRC_DIR) 
set(YOJIMBO_SRC_DIR "${YOJIMBO_ROOT}")
endif()

if (NOT YOJIMBO_INC_DIR) 
set(YOJIMBO_INC_DIR "${YOJIMBO_ROOT}/..")
endif()

if (NOT HL_INCLUDE_DIR) 
    set(HL_INCLUDE_DIR "/usr/local/include")
endif()

if (NOT HL_LIB_DIR) 
    set(HL_LIB_DIR "/usr/local/lib")
endif()

if (NOT COMMON_LIB_DIR) 
    set(COMMON_LIB_DIR "/usr/local/lib")
endif()

if (NOT HDLL_DESTINATION) 
    set(HDLL_DESTINATION "/usr/local/lib")
endif()

add_library(yojimbo.hdll SHARED
#Input C++ files go here
${YOJIMBO_SRC_DIR}/yojimbo.cpp
${YOJIMBO_SRC_DIR}/netcode.io/netcode.c
${YOJIMBO_SRC_DIR}/reliable.io/reliable.c
${YOJIMBO_SRC_DIR}/tlsf/tlsf.c
src/yojimbo.cpp
src/YojimboHelpers.cpp
src/hl_string_helpers.cpp
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
${YOJIMBO_INC_DIR}
${YOJIMBO_SRC_DIR}/netcode.io
${YOJIMBO_SRC_DIR}/reliable.io
${HL_INCLUDE_DIR}

)
#target_include_directories(yojimbo.hdll BEFORE PRIVATE )

link_directories(yojimbo.hdll
${HL_LIB_DIR}
/usr/local/include
)

find_library(LIBHL NAMES hl 
             HINTS ${HL_LIB_DIR} )

find_library(LIBSODIUM NAMES sodium)

find_library(LIBMBEDTLS NAMES mbedtls 
HINTS /usr/local/lib )

find_library(LIBMBEDCRYPTO NAMES mbedcrypto 
             HINTS /usr/local/lib )
find_library(LIBMBEDX509 NAMES mbedx509 
             HINTS /usr/local/lib )
             
             
target_link_libraries(yojimbo.hdll ${LIBHL} ${LIBMBEDTLS} ${LIBMBEDCRYPTO} ${LIBMBEDX509} ${LIBSODIUM})

if (UNIX)
    # Some special flags are needed for GNU GCC compiler
    SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++17 -fPIC  -O3  -fpermissive")
    #not sure why the ${HL_LIB_DIR} is necessary given the above.
    SET(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_MODULE_LINKER_FLAGS} -shared  ")
endif (UNIX)

install(TARGETS yojimbo.hdll DESTINATION ${HDLL_DESTINATION})
