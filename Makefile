COMPILER = clang
LINKER   = clang
RAYLIB_COMPILE_FLAGS = `pkg-config --cflags raylib`
RAYLIB_LINK_FLAGS    = `pkg-config --libs raylib` -lraygui
OPENGL_COMPILE_FLAGS = -Wno-deprecated-declarations -framework OpenGL
OPENGL_LINK_FLAGS    = -framework OpenGL
CPP_COMPILE_FLAGS    = -std=c++11 $(RAYLIB_COMPILE_FLAGS) $(OPENGL_COMPILE_FLAGS)
CPP_LINK_FLAGS       = -lstdc++ $(RAYLIB_LINK_FLAGS) $(OPENGL_LINK_FLAGS)

RELEASE_OBJECTS = source/data/vox-model.o             \
                  source/data/vox-model-editor.o      \
                  source/rendering/selection-buffer.o \
                  source/interface/toolbar.o          \
                  source/editor/action-stack.o        \
                  source/editor/editor.o              \
                  source/editor/main.o
DEBUG_OBJECTS = $(RELEASE_OBJECTS:.o=.debug.o)

# ===============================================

all: voxxy

release: voxxy

debug: voxxy-debug

# ===============================================

voxxy: $(RELEASE_OBJECTS)
	$(LINKER) $^ -o $@

voxxy-debug: $(DEBUG_OBJECTS)
	$(LINKER) $^ -o $@

%.debug.o: %.cpp
	$(COMPILER) $(CPP_COMPILE_FLAGS) --debug $^ -c -o $@

%.o: %.cpp
	$(COMPILER) $(CPP_COMPILE_FLAGS) $^ -c -o $@

# ===============================================

clean:
	rm -f $(RELEASE_OBJECTS)
	rm -f $(DEBUG_OBJECTS)

veryclean: clean
	rm -f voxxy
	rm -f voxxy-debug

remake: veryclean all
