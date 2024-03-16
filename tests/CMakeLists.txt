file(GLOB_RECURSE TEST_FILES ${CMAKE_CURRENT_LIST_DIR}/*.cpp)

add_executable(Tester ${TEST_FILES} ${SRC_FILES})

target_include_directories(Tester PUBLIC ${INCLUDE_DIR})

target_link_libraries(Tester PRIVATE ${GTEST_LINK} ${BOOST_INCLUDE_LIBRARIES})

include(GoogleTest)

gtest_discover_tests(Tester)

