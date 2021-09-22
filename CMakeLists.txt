cmake_minimum_required(VERSION 3.10)

add_library(yojimbo.hdll SHARED
#Input C++ files go here
${YOJIMBO_SRC_DIR}/yojimbo.cpp

src/yojimbo.cpp
ext/yojimbo/netcode.io/netcode.c
ext/yojimbo/reliable.io/reliable.c
ext/yojimbo/tlsf/tlsf.c
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
target_include_directories(yojimbo.hdll BEFORE PRIVATE /usr/local/Cellar/mbedtls@2/2.27.0/include )

link_directories(yojimbo.hdll
${HL_LIB_DIR}
/usr/local/Cellar/mbedtls@2/2.27.0/lib
)

find_library(LIBHL NAMES hl 
             HINTS ${HL_LIB_DIR} )

find_library(LIBSODIUM NAMES sodium)

find_library(LIBMBEDTLS NAMES mbedtls 
             HINTS /usr/local/Cellar/mbedtls@2/2.27.0/lib )

find_library(LIBMBEDCRYPTO NAMES mbedcrypto 
             HINTS /usr/local/Cellar/mbedtls@2/2.27.0/lib )

find_library(LIBMBEDX509 NAMES mbedx509 
             HINTS /usr/local/Cellar/mbedtls@2/2.27.0/lib )

             
             
target_link_libraries(yojimbo.hdll ${LIBHL} ${LIBMBEDTLS} ${LIBMBEDCRYPTO} ${LIBMBEDX509} ${LIBSODIUM})

if (UNIX)
    # Some special flags are needed for GNU GCC compiler
    SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++17 -fPIC  -O3  -fpermissive")
    #not sure why the ${HL_LIB_DIR} is necessary given the above.
    SET(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_MODULE_LINKER_FLAGS} -shared  ")
endif (UNIX)

install(TARGETS yojimbo.hdll DESTINATION ${HDLL_DESTINATION})
