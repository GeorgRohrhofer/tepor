cmake_minimum_required(VERSION 4.1.2)
project(NodeBackend LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Qt6 Module
find_package(Qt6 REQUIRED COMPONENTS Core Network)
set(CMAKE_AUTOMOC ON)

# FetchContent for nlohmann/json
include(FetchContent)
FetchContent_Declare(
    json
    GIT_REPOSITORY https://github.com/nlohmann/json.git
    GIT_TAG v3.12.0
)
FetchContent_MakeAvailable(json)

file(GLOB_RECURSE SOURCES CONFIGURE_DEPENDS
    "${PROJECT_SOURCE_DIR}/src/*.cpp"
    "${PROJECT_SOURCE_DIR}/include/NetworkManager.h"
    "${PROJECT_SOURCE_DIR}/include/ManagementNotifier.h"
    "${PROJECT_SOURCE_DIR}/include/MinecraftInstance.h"
)

add_subdirectory(libs/StringUtils)
add_subdirectory(libs/dockerlib)

add_executable(${PROJECT_NAME} ${SOURCES})
target_link_libraries(${PROJECT_NAME} PRIVATE StringUtils)
target_link_libraries(${PROJECT_NAME} PRIVATE dockerlib)
target_link_libraries(${PROJECT_NAME} PRIVATE nlohmann_json)

target_include_directories(${PROJECT_NAME}
    PRIVATE
        ${PROJECT_SOURCE_DIR}/include
)

if(MSVC)
    target_compile_options(${PROJECT_NAME} PRIVATE /W4 /permissive-)
else()
    target_compile_options(${PROJECT_NAME} PRIVATE -Wall -Wextra -Wpedantic)
endif()

install(TARGETS NodeBackend
    RUNTIME DESTINATION bin
)

install(TARGETS dockerlib
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

install(TARGETS nlohmann_json EXPORT NodeBackendTargets)

target_link_libraries(${PROJECT_NAME} PRIVATE
    Qt6::Core
    Qt6::Network
)
