file(GLOB_RECURSE SRC_FILES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} *.cpp)

target_sources(appTask-Management-App PRIVATE
    ${SRC_FILES}
)
