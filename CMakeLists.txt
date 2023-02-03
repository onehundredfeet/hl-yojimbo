cmake_minimum_required(VERSION 3.10)
project(yojimbo)


#message ("HOST IS APPLE ${CMAKE_HOST_APPLE}: ${CMAKE_HOST_SYSTEM_NAME}")
if (CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin")
#OSX Configuration details
if (TARGET_ARCH STREQUAL "x86" OR TARGET_ARCH STREQUAL "x64")
    set(TARGET_ARCH "x86_64")
endif()

if (TARGET_ARCH STREQUAL "arm")
    set(TARGET_ARCH "arm64")
endif()

if (TARGET_ARCH STREQUAL "x86_64")
    set(BREW_ROOT "/usr/local")
endif()

if (TARGET_ARCH STREQUAL "arm64")
    set(LOCAL_LIB "/opt/homebrew/lib")
    set(LOCAL_INC "/opt/homebrew/include")
endif()

set(CELLAR_ROOT "${BREW_ROOT}/Cellar")
set(LOCAL_LIB "${BREW_ROOT}/lib")
set(LOCAL_INC "${BREW_ROOT}/include")

set(CMAKE_OSX_ARCHITECTURES ${TARGET_ARCH})

if (NOT MBEDTLS_INC_DIR)
    set(MBEDTLS_INC_DIR "${CELLAR_ROOT}/mbedtls/3.1.0/include")
endif()

if (NOT MBEDTLS_LIB_DIR)
    set(MBEDTLS_LIB_DIR "${CELLAR_ROOT}/mbedtls/3.1.0/lib")
endif()

endif()

if (NOT TARGET_HOST)
    set(TARGET_HOST "hl")
endif()


if (NOT YOJIMBO_ROOT) 
set(YOJIMBO_ROOT "ext/yojimbo")
endif()

if (NOT YOJIMBO_SRC_DIR) 
set(YOJIMBO_SRC_DIR "${YOJIMBO_ROOT}")
endif()

if (NOT YOJIMBO_INC_DIR) 
set(YOJIMBO_INC_DIR "${YOJIMBO_ROOT}/..")
endif()

if (TARGET_HOST STREQUAL "hl")
if (NOT TARGET_INCLUDE_DIR) 
    set(TARGET_INCLUDE_DIR ${LOCAL_INC})
endif()

if (NOT TARGET_LIB_DIR) 
    set(TARGET_LIB_DIR ${LOCAL_LIB})
endif()

set(TARGET_LIB_NAME "${CMAKE_PROJECT_NAME}.hdll")
find_library(LIBHL NAMES hl  HINTS ${TARGET_LIB_DIR} )
set(TARGET_LIBS ${LIBHL})

elseif(TARGET_HOST STREQUAL "jvm")



find_package(JNI)

if (JNI_FOUND)
    message (STATUS "JNI_INCLUDE_DIRS=${JNI_INCLUDE_DIRS}")
    message (STATUS "JNI_LIBRARIES=${JNI_LIBRARIES}")
else()
    execute_process(COMMAND "/usr/libexec/java_home" OUTPUT_VARIABLE JAVA_HOME OUTPUT_STRIP_TRAILING_WHITESPACE)
    set(JNI_INCLUDE_DIRS "${JAVA_HOME}/include" "${JAVA_HOME}/include/darwin")
    set(JNI_LIBRARIES "${JAVA_HOME}/lib")
endif()

if (NOT TARGET_INCLUDE_DIR) 
    set(TARGET_INCLUDE_DIR ${JNI_INCLUDE_DIRS})
endif()

if (NOT TARGET_LIB_DIR) 
    set(TARGET_LIB_DIR ${JNI_LIBRARIES})
endif()

message (STATUS "JNI_INCLUDE_DIRS=${JNI_INCLUDE_DIRS}")
message (STATUS "JNI_LIBRARIES=${JNI_LIBRARIES}")

set(TARGET_LIB_NAME "${CMAKE_PROJECT_NAME}.dylib")
set(TARGET_LIBS )
endif() #hl


add_library(${TARGET_LIB_NAME} SHARED
#Input C++ files go here
${YOJIMBO_SRC_DIR}/yojimbo.cpp
${YOJIMBO_SRC_DIR}/netcode.io/netcode.c
${YOJIMBO_SRC_DIR}/reliable.io/reliable.c
${YOJIMBO_SRC_DIR}/tlsf/tlsf.c
src/yojimbo_${TARGET_HOST}.cpp
#src/YojimboHelpers_${TARGET_HOST}.cpp
#src/hl_string_helpers.cpp
)

set_target_properties(${TARGET_LIB_NAME}
PROPERTIES
PREFIX ""
OUTPUT_NAME yojimbo
SUFFIX .hdll
)

cmake_policy(SET CMP0015 NEW)

target_include_directories(${TARGET_LIB_NAME}
PRIVATE
${MBEDTLS_INC_DIR}
${YOJIMBO_INC_DIR}
${YOJIMBO_SRC_DIR}/netcode.io
${YOJIMBO_SRC_DIR}/reliable.io
${TARGET_INCLUDE_DIR}
${BREW_INCLUDE_DIR}
${LOCAL_INC}
)
#target_include_directories(yojimbo.hdll BEFORE PRIVATE )

link_directories(${TARGET_LIB_NAME}
${TARGET_LIB_DIR}
${LOCAL_LIB}
)



find_library(LIBSODIUM NAMES sodium  HINTS ${LOCAL_LIB})
find_library(LIBMBEDTLS NAMES mbedtls HINTS ${MBEDTLS_LIB_DIR} )

find_library(LIBMBEDCRYPTO NAMES mbedcrypto 
             HINTS ${LOCAL_LIB} )
find_library(LIBMBEDX509 NAMES mbedx509 
             HINTS ${LOCAL_LIB} )
             
             
target_link_libraries(${TARGET_LIB_NAME} ${TARGET_LIBS} ${LIBMBEDTLS} ${LIBMBEDCRYPTO} ${LIBMBEDX509} ${LIBSODIUM})

if (UNIX)
    # Some special flags are needed for GNU GCC compiler
    SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++17 -fPIC  -O3  -fpermissive")
    #not sure why the ${HL_LIB_DIR} is necessary given the above.
    SET(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_MODULE_LINKER_FLAGS} -shared  ")
endif (UNIX)

install(TARGETS ${TARGET_LIB_NAME})
