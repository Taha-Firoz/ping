cmake_minimum_required(VERSION 3.15)
set(PROJECT_NAME "ping")
project(${PROJECT_NAME} LANGUAGES CXX)

# This value is used when generating builds using this plugin, so it must
# not be changed
set(PLUGIN_NAME "ping_plugin")

add_library(${PLUGIN_NAME} SHARED "ping_plugin.cc" "miniaudio.cc")
apply_standard_settings(${PLUGIN_NAME})
set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden)
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)
target_include_directories(${PLUGIN_NAME} INTERFACE "${CMAKE_CURRENT_SOURCE_DIR}/include" )
target_link_libraries(${PLUGIN_NAME} PRIVATE flutter flutter_wrapper_plugin)

set(THREADS_PREFER_PTHREAD_FLAG ON)
find_package(Threads REQUIRED)
set(LIB_PTHREAD Threads::Threads)
set(LIB_MATH m)
# Link miniaudio -lpthread, -ldl & libmath(no checks if libmath already in libc)
target_link_libraries(${PLUGIN_NAME} 
    PRIVATE
    ${LIB_PTHREAD} 
    ${LIB_MATH} 
    ${CMAKE_DL_LIBS}
)

# List of absolute paths to libraries that should be bundled with the plugin
set(ping_bundled_libraries
  ""
  PARENT_SCOPE
)



################################################

# cmake_minimum_required(VERSION 3.15)
# set(PROJECT_NAME "ping")
# project(${PROJECT_NAME} LANGUAGES CXX)
# set(CMAKE_CXX_STANDARD 17)
# set(CMAKE_CXX_STANDARD_REQUIRED ON)

# # This value is used when generating builds using this plugin, so it must
# # not be changed
# set(PLUGIN_NAME "ping_plugin")

# add_library(${PLUGIN_NAME} SHARED
#   "ping_plugin.cc"
# )
# apply_standard_settings(${PLUGIN_NAME})

# set_target_properties(${PLUGIN_NAME} PROPERTIES CXX_VISIBILITY_PRESET hidden)
# target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)
# target_include_directories(${PLUGIN_NAME} INTERFACE ${CMAKE_CURRENT_SOURCE_DIR}/include )
# target_link_libraries(${PLUGIN_NAME} PRIVATE flutter flutter_wrapper_plugin pthread m ${CMAKE_DL_LIBS})
# # set(THREADS_PREFER_PTHREAD_FLAG ON)
# # find_package(Threads REQUIRED)
# # set(LIB_PTHREAD Threads::Threads)
# # set(LIB_MATH m)
# # # Link miniaudio -lpthread, -ldl & libmath(no checks if libmath already in libc)
# # target_link_libraries(${PLUGIN_NAME} 
# #     ${LIB_PTHREAD} 
# #     ${LIB_MATH} 
# #     ${CMAKE_DL_LIBS}
# # )

# # List of absolute paths to libraries that should be bundled with the plugin
# set(ping_bundled_libraries
#   ""
#   PARENT_SCOPE
# )
