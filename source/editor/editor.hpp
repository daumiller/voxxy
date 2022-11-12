#ifndef EDITOR_HEADER
#define EDITOR_HEADER

#include "../data/vxx-model-editor.hpp"
#include "../editor/action-stack.hpp"
#include "../interface/toolbar.hpp"
#include "../interface/color-picker.hpp"
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

class Editor {
public:
  Editor();
  ~Editor();
  void mainLoop();

  void handleUiAction(uint32_t ui_action);
  void handleFrameSelected(const char* frame_name);
  void handleColorSelected(uint32_t color);
  void handleModalModelOpen(const char* path);
  void handleModalPaletteOpen(const char* path);

  void performAction(Action action);

  uint32_t                 selected_color;
protected:
  EditorTool               selected_tool;
  std::vector<VxxVoxel>    selected_voxels;
  EditorSelectionRectangle selected_rectangle;
  VxxModelEditor           current_model;
  const char*              current_model_path;
  VxxModelFrameEditor*     current_model_frame;
  const char*              current_model_frame_name;
  EditorModalType          active_modal;
  SelectionBuffer          selection_buffer;
  int32_t                  screen_width_previous;
  int32_t                  screen_height_previous;
  bool                     ui_frames_expanded;
  bool                     ui_colors_expanded;
  Toolbar*                 ui_main_toolbar;
  ColorPicker*             ui_color_picker;
  bool                     running;
  std::vector<VxxVisibleVoxel>* visible_voxels;
  std::unordered_map<std::string, ActionStack> frame_action_stacks;

  const char* pathForResource(const char* filename);
  void renderModel(bool for_selection_buffer, Shader* shader_default, SelectionBufferId* selection_id);
};

#endif // ifndef EDITOR_HEADER
