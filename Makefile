COMPILER = clang
LINKER   = clang
RAYLIB_COMPILE_FLAGS = `pkg-config --cflags raylib`
RAYLIB_LINK_FLAGS    = `pkg-config --libs raylib` -lraygui
OPENGL_COMPILE_FLAGS = -Wno-deprecated-declarations
OPENGL_LINK_FLAGS    = -framework OpenGL
OBJFW_COMPILE_FLAGS  = -I/usr/local/include `objfw-config --objcflags`
OBJFW_LINK_FLAGS     = `objfw-config --ldflags --libs`
OBJC_COMPILE_FLAGS   = $(OBJFW_COMPILE_FLAGS) $(RAYLIB_COMPILE_FLAGS) $(OPENGL_COMPILE_FLAGS) -std=c99
OBJC_LINK_FLAGS      = $(OBJFW_LINK_FLAGS)    $(RAYLIB_LINK_FLAGS)    $(OPENGL_LINK_FLAGS)

RELEASE_OBJECTS = source/rendering/selection-buffer.o \
                  source/data/voxel-model.o           \
                  source/data/voxel-model-editor.o    \
                  source/data/voxfile.o               \
                  source/interface/toolbar.o          \
                  source/interface/color-picker.o     \
                  source/editor/action-stack.o        \
                  source/editor/voxel-face-models.o   \
                  source/editor/editor-state.o        \
                  source/editor/editor.o              \
                  source/main.o
DEBUG_OBJECTS = $(RELEASE_OBJECTS:.o=.debug.o)

# ===============================================

all: voxxy

release: voxxy

debug: voxxy-debug

# ===============================================

voxxy: $(RELEASE_OBJECTS)
	$(LINKER) $(OBJC_LINK_FLAGS) $^ -o $@

voxxy-debug: $(DEBUG_OBJECTS)
	$(LINKER) $(OBJC_LINK_FLAGS) $^ -o $@

%.debug.o: %.m
	$(COMPILER) $(OBJC_COMPILE_FLAGS) --debug $^ -c -o $@

%.o: %.m
	$(COMPILER) $(OBJC_COMPILE_FLAGS) $^ -c -o $@

# ===============================================

clean:
	rm -f $(RELEASE_OBJECTS)
	rm -f $(DEBUG_OBJECTS)

veryclean: clean
	rm -f voxxy
	rm -f voxxy-debug

remake: veryclean all

compile_commands:
	bear -- make
