cmake_minimum_required(VERSION 4.1.2)
project(DockerLib VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# Options
option(BUILD_SHARED_LIBS "Build shared libraries" OFF)

# Find CURL
find_package(CURL REQUIRED)

# FetchContent for nlohmann/json
include(FetchContent)
FetchContent_Declare(
    json
    GIT_REPOSITORY https://github.com/nlohmann/json.git
    GIT_TAG v3.12.0
)
FetchContent_MakeAvailable(json)

# Library
add_library(dockerlib
    src/dockerlib.cpp
)

target_include_directories(dockerlib
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<INSTALL_INTERFACE:include>
)

target_link_libraries(dockerlib
    PUBLIC
        CURL::libcurl
        StringUtils
    PRIVATE
        nlohmann_json::nlohmann_json
)

install(TARGETS nlohmann_json EXPORT DockerLibTargets)
install(TARGETS StringUtils EXPORT DockerLibTargets)

# Installation
install(TARGETS dockerlib
    EXPORT DockerLibTargets
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
    INCLUDES DESTINATION include
)

install(DIRECTORY include/
    DESTINATION include
)

install(EXPORT DockerLibTargets
    FILE DockerLibTargets.cmake
    NAMESPACE DockerLib::
    DESTINATION lib/cmake/DockerLib
)

# Config files
include(CMakePackageConfigHelpers)
write_basic_package_version_file(
    "${CMAKE_CURRENT_BINARY_DIR}/DockerLibConfigVersion.cmake"
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY AnyNewerVersion
)

configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/DockerLibConfig.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/DockerLibConfig.cmake"
    @ONLY
)

install(FILES
    "${CMAKE_CURRENT_BINARY_DIR}/DockerLibConfig.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/DockerLibConfigVersion.cmake"
    DESTINATION lib/cmake/DockerLib
)
