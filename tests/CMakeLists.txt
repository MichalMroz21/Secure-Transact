file(GLOB_RECURSE TEST_FILES ${CMAKE_CURRENT_LIST_DIR}/*.cpp)

qt_add_executable(Tester)

list(REMOVE_ITEM SOURCE_FILES ${SOURCE_DIR}/main.cpp)

#MOC requires to have include files sourced.
target_sources(Tester PRIVATE
    ${TEST_FILES} ${SOURCE_FILES} ${INCLUDE_FILES}
)

target_include_directories(Tester PUBLIC ${INCLUDE_DIR} ${Boost_INCLUDE_DIRS})

target_link_libraries(Tester PRIVATE ${GTEST_LINK} ${Boost_LIBRARIES} ${QT_INCLUDE_LIBRARIES})

include(GoogleTest)

#Discovery mode has to be PRE_TEST, because it won't work without it, yes.
gtest_discover_tests(Tester DISCOVERY_MODE PRE_TEST)
