cmake_minimum_required(VERSION 3.21.1)

project(SecureTransactApp LANGUAGES CXX)

#Set project options
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_AUTOMOC ON)
set(BOOST_ENABLE_CMAKE ON)
set(MAKE_TEST_EXE ON)
set(Boost_COMPILER "mgw9")
set(Boost_USE_STATIC_RUNTIME ON)

option(BUILD_QDS_COMPONENTS "Build design studio components" ON)

#Set used components
set(QT_COMPONENTS Core Gui Qml Quick)
set(BOOST_COMPONENTS regex filesystem)
set(GTEST_LINK gtest_main gmock_main)

#Set constant variables
set(QT_QML_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/qml)
set(CONFIGS_DIR ${CMAKE_CURRENT_SOURCE_DIR}/configs)
set(SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/source)
set(INCLUDE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/include)
set(CMAKE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/cmake)
set(QML_IMPORT_PATH ${QT_QML_OUTPUT_DIRECTORY}
    CACHE STRING "Import paths for Qt Creator's code model"
    FORCE
)

#Get all files in folders
file(GLOB_RECURSE CONFIG_FILES_RELATIVE RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} ${CONFIGS_DIR}/*.conf ${CONFIGS_DIR}/*.json)
file(GLOB_RECURSE INCLUDE_FILES ${INCLUDE_DIR}/*.h ${INCLUDE_DIR}/*.hpp)
file(GLOB_RECURSE SOURCE_FILES ${SOURCE_DIR}/*.cpp ${SOURCE_DIR}/*.c)

#CMakeConfig.hpp Constants
add_definitions(-DROOT_PATH_CMAKE=${CMAKE_CURRENT_SOURCE_DIR})

#Macros
include(${CMAKE_DIR}/UpdateSubmodules.cmake)

#QT6 is required to be installed
find_package(Qt6 6.2 REQUIRED COMPONENTS ${QT_COMPONENTS})

#Boost has to be installed on operating system
find_package(Boost REQUIRED COMPONENTS ${BOOST_COMPONENTS})

#GTest can be downloaded via git submodules
if(MAKE_TEST_EXE)
    find_package(GTest)
endif()

add_subdirectory(dependencies)

if (Qt6_VERSION VERSION_GREATER_EQUAL 6.3)
    qt_standard_project_setup()
endif()

qt_add_executable(SecureTransactApp ${SOURCE_FILES}
)

qt_add_resources(SecureTransactApp "configs"
    PREFIX "/"
    FILES ${CONFIG_FILES_RELATIVE}
)

qt_policy(SET QTP0001 NEW)

#Transform library names into proper form for linking
list(TRANSFORM QT_COMPONENTS PREPEND "Qt6::")
list(TRANSFORM GTEST_LINK PREPEND "GTest::")

target_link_libraries(SecureTransactApp PRIVATE
    ${QT_COMPONENTS} ${Boost_LIBRARIES}
)

target_sources(SecureTransactApp PRIVATE ${INCLUDE_FILES})

target_include_directories(SecureTransactApp PRIVATE ${Boost_INCLUDE_DIRS} ${INCLUDE_DIR})

#Create separate Tester executables that runs tests
if(MAKE_TEST_EXE)
    include(CTest)
    add_subdirectory(tests)
endif()

#Design Studio Components
if (BUILD_QDS_COMPONENTS)
    include(${CMAKE_CURRENT_SOURCE_DIR}/qmlcomponents)
endif()

include(${CMAKE_CURRENT_SOURCE_DIR}/qmlmodules)

include(GNUInstallDirs)

install(TARGETS SecureTransactApp
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

target_link_libraries(SecureTransactApp PRIVATE Quick3DAssetsplugin)

# make IDEs aware of the QML import path
set(QML_IMPORT_PATH ${PROJECT_BINARY_DIR}/qml CACHE PATH
    "Path to the custom QML components defined by the project")
