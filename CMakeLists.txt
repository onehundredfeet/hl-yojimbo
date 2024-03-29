cmake_minimum_required(VERSION 3.10)
#you need to modify this yourself
project(yojimbo)

if (NOT PATH_TO_IDL) 
set(PATH_TO_IDL "../hl-idl")
endif()

# a bunch of pre-configured options that may or may not be useful
# it attempts to cover most of what is used for basic libraries
# you can reference the paths defined here to help make your cmake code more portable
include(${PATH_TO_IDL}/h-idl-defines.cmake)

if (NOT YOJIMBO_ROOT) 
set(YOJIMBO_ROOT "ext/yojimbo")
endif()

if (NOT YOJIMBO_SRC_DIR) 
set(YOJIMBO_SRC_DIR "${YOJIMBO_ROOT}")
endif()

if (NOT YOJIMBO_INC_DIR) 
set(YOJIMBO_INC_DIR "${YOJIMBO_ROOT}/..")
endif()

set( PROJECT_ADDITIONAL_SOURCES 
${YOJIMBO_SRC_DIR}/yojimbo.cpp
${YOJIMBO_SRC_DIR}/netcode.io/netcode.c
${YOJIMBO_SRC_DIR}/reliable.io/reliable.c
${YOJIMBO_SRC_DIR}/tlsf/tlsf.c
)

set (PROJECT_ADDITIONAL_INCLUDES
${YOJIMBO_INC_DIR}
${YOJIMBO_SRC_DIR}/netcode.io
${YOJIMBO_SRC_DIR}/reliable.io
)

set (PROJECT_ADDITIONAL_LIB_DIRS
# otherlib/lib
)

find_library(LIBSODIUM NAMES sodium  HINTS ${LOCAL_LIB})
find_library(LIBMBEDTLS NAMES mbedtls HINTS ${LOCAL_LIB} )

find_library(LIBMBEDCRYPTO NAMES mbedcrypto 
             HINTS ${LOCAL_LIB} )
find_library(LIBMBEDX509 NAMES mbedx509 
             HINTS ${LOCAL_LIB} )

             
set(PROJECT_ADDITIONAL_LIBS
${LIBSODIUM}
${LIBMBEDTLS}
${LIBMBEDCRYPTO}
${LIBMBEDX509}
)           

include(${PATH_TO_IDL}/h-idl-configure.cmake)


