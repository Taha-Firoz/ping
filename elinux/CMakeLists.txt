cmake_minimum_required(VERSION 3.15)
set(PROJECT_NAME "ping")
project(${PROJECT_NAME} LANGUAGES CXX)

# This value is used when generating builds using this plugin, so it must
# not be changed
set(PLUGIN_NAME "ping_plugin")
set(CMAKE_VERBOSE_MAKEFILE ON)
find_package(PkgConfig)
set(BUILD_SHARED_LIBS ON)
add_library(${PLUGIN_NAME} SHARED "ping_plugin.cc" "miniaudio.cc")
pkg_check_modules(GLIB REQUIRED glib-2.0)
apply_standard_settings(${PLUGIN_NAME})
set_target_properties(${PLUGIN_NAME} PROPERTIES CXX_VISIBILITY_PRESET hidden)
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)
target_include_directories(${PLUGIN_NAME} INTERFACE "${CMAKE_CURRENT_SOURCE_DIR}/include" )
target_link_libraries(${PLUGIN_NAME} PRIVATE flutter flutter_wrapper_plugin)

set(THREADS_PREFER_PTHREAD_FLAG ON)
find_package(Threads REQUIRED)
set(LIB_PTHREAD Threads::Threads)
include(CheckLibraryExists)
CHECK_LIBRARY_EXISTS(m sin "" HAVE_LIB_M)                                                                                                                                                                                                                                         
if (HAVE_LIB_M)                                                                                                                          
    set(EXTRA_LIBS ${EXTRA_LIBS} m)                                                                                                      
endif (HAVE_LIB_M)

# set(LIB_MATH m)
# Link miniaudio -lpthread, -ldl & libmath(no checks if libmath already in libc)
target_link_libraries(${PLUGIN_NAME} 
    PRIVATE
    ${LIB_PTHREAD}
    # Link absolute path to libmath and libdl
    ${CMAKE_SYSROOT}/lib/aarch64-linux-gnu/libdl.so.2
    ${CMAKE_SYSROOT}/lib/aarch64-linux-gnu/libm.so.6
)

target_include_directories(${PLUGIN_NAME}
  PRIVATE
    ${GLIB_INCLUDE_DIRS}
)

target_link_libraries(${PLUGIN_NAME}
  PRIVATE
    ${GLIB_LIBRARIES}
)

# List of absolute paths to libraries that should be bundled with the plugin
set(ping_bundled_libraries
  ""
  PARENT_SCOPE
)