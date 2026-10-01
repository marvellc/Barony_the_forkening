message(STATUS "=== ENTERED src/imgui/CMakeLists.txt ===")
include(FetchContent)

set(IMGUI_TAG "v1.92.9b-docking")

FetchContent_Declare(
        imgui
        GIT_REPOSITORY https://github.com/ocornut/imgui.git
        GIT_TAG        ${IMGUI_TAG}
        GIT_SHALLOW    TRUE
)

FetchContent_MakeAvailable(imgui)

message(STATUS "Dear ImGui tag:    ${IMGUI_TAG}")
message(STATUS "Dear ImGui source: ${imgui_SOURCE_DIR}")

add_library(barony_imgui STATIC
        ${imgui_SOURCE_DIR}/imgui.cpp
        ${imgui_SOURCE_DIR}/imgui_draw.cpp
        ${imgui_SOURCE_DIR}/imgui_tables.cpp
        ${imgui_SOURCE_DIR}/imgui_widgets.cpp

        # Keep this initially while bringing the new editor up.
        ${imgui_SOURCE_DIR}/imgui_demo.cpp

        ${imgui_SOURCE_DIR}/backends/imgui_impl_sdl2.cpp
        ${imgui_SOURCE_DIR}/backends/imgui_impl_opengl3.cpp
)

target_include_directories(barony_imgui PUBLIC
        ${imgui_SOURCE_DIR}
        ${imgui_SOURCE_DIR}/backends
)

target_include_directories(barony_imgui PRIVATE
        ${SDL2_INCLUDE_DIRS}
        ${SDL2_INCLUDE_DIR}
)

target_link_libraries(barony_imgui
        ${SDL2_LIBRARIES}
        ${SDL2_LIBRARY}
        ${OPENGL_LIBRARIES}
)