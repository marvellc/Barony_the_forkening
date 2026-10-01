include(FetchContent)

FetchContent_Declare(
        imgui
        GIT_REPOSITORY https://github.com/ocornut/imgui.git
        GIT_TAG docking
        GIT_SHALLOW TRUE
)

FetchContent_MakeAvailable(imgui)

add_library(barony_imgui STATIC
        ${imgui_SOURCE_DIR}/imgui.cpp
        ${imgui_SOURCE_DIR}/imgui_draw.cpp
        ${imgui_SOURCE_DIR}/imgui_tables.cpp
        ${imgui_SOURCE_DIR}/imgui_widgets.cpp

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

target_link_libraries(barony_imgui PUBLIC
        ${SDL2_LIBRARIES}
        ${SDL2_LIBRARY}
        ${OPENGL_LIBRARIES}
)