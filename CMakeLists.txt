cmake_minimum_required(VERSION 3.24)

project(Task-Management-App VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_DIR ${CMAKE_CURRENT_LIST_DIR}/cmake)
set(INCLUDE_DIR ${CMAKE_CURRENT_LIST_DIR}/include)

set(BOOST_INCLUDE_LIBRARIES describe type_index endian algorithm)
set(BOOST_ENABLE_CMAKE ON)

set(QT_INCLUDE_LIBRARIES Quick)

option(MAKE_TEST_EXE "Run GTests" ON)

#CMakeConfig.hpp Constants
add_definitions(-DROOT_PATH_CMAKE=${CMAKE_CURRENT_SOURCE_DIR})
include(GNUInstallDirs)

#Macros
include(${CMAKE_DIR}/UpdateSubmodules.cmake)
include(${CMAKE_DIR}/AddFiles.cmake)

find_package(Qt6 6.4 COMPONENTS ${QT_INCLUDE_LIBRARIES})

add_subdirectory(dependencies)

qt_standard_project_setup()
qt_add_executable(appTask-Management-App)
qt_policy(SET QTP0001 NEW)

add_subdirectory(include)
add_subdirectory(source)
add_subdirectory(source_gui)

target_include_directories(appTask-Management-App PRIVATE
    ${INCLUDE_DIR}
)

list(TRANSFORM BOOST_INCLUDE_LIBRARIES PREPEND "Boost::")
list(TRANSFORM QT_INCLUDE_LIBRARIES PREPEND "Qt6::")

target_link_libraries(appTask-Management-App
    PRIVATE ${GTEST_LINK} ${BOOST_INCLUDE_LIBRARIES} ${QT_INCLUDE_LIBRARIES}
)

qt_add_qml_module(appTask-Management-App
    URI Task-Management-App
    VERSION 1.0
    RESOURCE_PREFIX "/"

    QML_FILES ${QML_FILES}
    RESOURCES ${RESOURCES}
)

if(MAKE_TEST_EXE)
    include(CTest)
    add_subdirectory(tests)
endif()

set_target_properties(appTask-Management-App PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

install(TARGETS appTask-Management-App
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

#cmake -B build -S . -G "MinGW Makefiles" && cd build && make && cd ..
#cmake -B build -S . -G "MinGW Makefiles" && cd build && make && cd tests && export GTEST_COLOR=1 && ./Tester.exe
