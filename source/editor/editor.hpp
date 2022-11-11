#ifndef EDITOR_HEADER
#define EDITOR_HEADER

#include "../data/vxx-model-editor.hpp"
#include "../editor/action-stack.hpp"
#include "../interface/toolbar.hpp"
#include "../rendering/selection-buffer.hpp"
#include <stdbool.h>

typedef enum {
  EditorTool_Add,
  EditorTool_Erase,
  EditorTool_ColorSet,
  EditorTool_ColorGet,
  EditorTool_Select,
  EditorTool_Move,
} EditorTool;

typedef struct {
  uint32_t start_x;
  uint32_t start_y;
  uint32_t current_x;
  uint32_t current_y;
  bool     still_moving;
} EditorSelectionRectangle;

typedef enum {
  EditorModalType_None,
  EditorModalType_ModelOpen,
  EditorModalType_ModelSaveAs,
  EditorModalType_ModelSaveBeforeUnloading,
  EditorModalType_PaletteOpen,
  EditorModalType_PaletteSaveAs,
  EditorModalType_Settings,
} EditorModalType;

// keep track of:
//   - currently selected tool
//   - currently selected color
//   - currently selected voxels
//   - current selection rectangle
//   - current model file, including file path
//   - currently active frame
//   - currently active modal
//   - selection_buffer
//   - per-frame action stack

// handle:
//   - toolbar press events
//   - frame selection events
//   - color selection events
//   - file & palette load events
//   - file & palette new events
//   - main loop, w/:
//     - rendering selection buffer
//     - rendering visible buffer
//     - non-ui click & drag events
//     - non-ui keypress events

class Editor {
public:
  Editor();
  void mainLoop();

protected:
  EditorTool               selected_tool;
  uint32_t                 selected_color;
  std::vector<VxxVoxel>    selected_voxels;
  EditorSelectionRectangle selected_rectangle;
  VxxModel                 current_model;
  const char*              current_model_path;
  VxxModelFrame*           current_model_frame;
  const char*              current_model_frame_name;
  EditorModalType          active_modal;
  SelectionBuffer          selection_buffer;
  std::unordered_map<std::string, ActionStack> frame_action_stacks;

  void handleToolbarClick(ToolbarItem* item); // handles main toolbar, animations toolbar, and colors toolbar
  void handleFrameSelected(const char* frame_name);
  void handleColorSelected(uint32_t color);
  void handleModalModelOpen(const char* path);
  void handleModalModelNew();
  void handleModalPaletteOpen(const char* path);
  void handleModalPaletteNew();
  void handleQuitRequested();

  void renderModel(bool for_selection_buffer);
  void renderUI();
};

#endif // ifndef EDITOR_HEADER
