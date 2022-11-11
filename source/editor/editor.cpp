#include "editor.hpp"
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <libproc.h>
#include <raylib.h>
#include <raygui.h>
#include "editor-face-models.hpp"

#define MAX_ACTION_STACK_DEPTH 1024

static VoxelFaceModels voxel_face_models;
static bool voxel_face_models_generated = false;

#define UI_ACTION_NONE             0
#define UI_ACTION_MODEL_NEW        1
#define UI_ACTION_MODEL_OPEN       2
#define UI_ACTION_MODEL_SAVE       3
#define UI_ACTION_TOOL_PLACE       4
#define UI_ACTION_TOOL_ERASE       5
#define UI_ACTION_TOOL_PAINT       6
#define UI_ACTION_TOOL_SELECT      7
#define UI_ACTION_TOOL_MOVE        8
#define UI_ACTION_TOOL_INSPECT     9
#define UI_ACTION_SETTINGS_OPEN   10
#define UI_ACTION_FRAMES_EXPAND   11
#define UI_ACTION_COLORS_EXPAND   12
#define UI_ACTION_QUIT_REQUESTED 255

class ToolbarMain : public Toolbar {
public:
  ToolbarMain(ToolbarStyle style, Editor* editor);
  void onClick(ToolbarItem* item);
  void setActiveId(uint32_t active_id);
protected:
  Editor* editor;
};
ToolbarMain::ToolbarMain(ToolbarStyle style, Editor* editor) : Toolbar(style) { this->editor = editor; }
void ToolbarMain::onClick(ToolbarItem* item) { if(editor) { editor->handleUiAction(item->id); } }
void ToolbarMain::setActiveId(uint32_t active_id) {
  std::vector<ToolbarItem>::iterator item_iterator = items.begin();
  while(item_iterator != items.end()) {
    if(item_iterator->id == active_id) {
      item_iterator->is_active = true;
    } else {
      item_iterator->is_active = false;
    }
    ++item_iterator;
  }
}

static bool selectionIdsSameVoxel(SelectionBufferId a, SelectionBufferId b) {
  if(a.voxel_x != b.voxel_x) { return false; }
  if(a.voxel_y != b.voxel_y) { return false; }
  if(a.voxel_z != b.voxel_z) { return false; }
  return true;
}

static inline Color raylibColorFromUint32(uint32_t uint32_color) {
    return {
      .r = (uint8_t)((uint32_color & 0xFF000000) >> 24),
      .g = (uint8_t)((uint32_color & 0x00FF0000) >> 16),
      .b = (uint8_t)((uint32_color & 0x0000FF00) >>  8),
      .a = (uint8_t)((uint32_color & 0x000000FF) >>  0),
    };
}

Editor::Editor() {
  visible_voxels = NULL;

  selected_tool                   = EditorTool_Add;
  selected_color                  = 0xFF00FFFF;
  selected_rectangle.still_moving = false;
  current_model_path              = NULL;
  active_modal                    = EditorModalType_None;
  screen_width_previous           = -1;
  screen_height_previous          = -1;
  ui_frames_expanded              = false;
  ui_colors_expanded              = false;
  running                         = true;

  ToolbarItem main_toolbar_items[] = {
    { .id=UI_ACTION_MODEL_NEW,     .icon="#8#",   .is_visible=true, .is_enabled=true, .is_active=false, .is_group_end=false },
    { .id=UI_ACTION_MODEL_OPEN,    .icon="#1#",   .is_visible=true, .is_enabled=true, .is_active=false, .is_group_end=false },
    { .id=UI_ACTION_MODEL_SAVE,    .icon="#2#",   .is_visible=true, .is_enabled=true, .is_active=false, .is_group_end=true  },
    { .id=UI_ACTION_TOOL_PLACE,    .icon="#22#",  .is_visible=true, .is_enabled=true, .is_active=true,  .is_group_end=false },
    { .id=UI_ACTION_TOOL_ERASE,    .icon="#28#",  .is_visible=true, .is_enabled=true, .is_active=false, .is_group_end=false },
    { .id=UI_ACTION_TOOL_PAINT,    .icon="#24#",  .is_visible=true, .is_enabled=true, .is_active=false, .is_group_end=false },
    { .id=UI_ACTION_TOOL_SELECT,   .icon="#21#",  .is_visible=true, .is_enabled=true, .is_active=false, .is_group_end=false },
    { .id=UI_ACTION_TOOL_MOVE,     .icon="#32#",  .is_visible=true, .is_enabled=true, .is_active=false, .is_group_end=false },
    { .id=UI_ACTION_TOOL_INSPECT,  .icon="#27#",  .is_visible=true, .is_enabled=true, .is_active=false, .is_group_end=true  },
    { .id=UI_ACTION_NONE,          .icon=NULL,    .is_visible=true, .is_enabled=true, .is_active=false, .is_group_end=false },
    { .id=UI_ACTION_NONE,          .icon=NULL,    .is_visible=true, .is_enabled=true, .is_active=false, .is_group_end=false },
    { .id=UI_ACTION_SETTINGS_OPEN, .icon="#142#", .is_visible=true, .is_enabled=true, .is_active=false, .is_group_end=false },
  };
  ToolbarMain* toolbar_main = new ToolbarMain(ToolbarStyle_Grouped, this);
  toolbar_main->appendItems(main_toolbar_items, 12);
  ui_main_toolbar = toolbar_main;

  current_model_frame_name = "untitled";
  VxxModelFrameEditor frame;
  frame.addVoxel({ .x=0, .y=0, .z=0, .color=0xFF00FFFF });
  current_model.addFrame(current_model_frame_name, frame);
  current_model_frame = (VxxModelFrameEditor*)(current_model.getFrame(current_model_frame_name));
  visible_voxels = frame.getVisibleVoxels();

  frame_action_stacks[current_model_frame_name] = ActionStack(MAX_ACTION_STACK_DEPTH);
}

Editor::~Editor() {
  if(current_model_path) { free((void*)current_model_path); }
  if(ui_main_toolbar) { delete ui_main_toolbar; }
}

const char* Editor::pathForResource(const char* filename) {
  // first, get path to current process's executable
  pid_t process_pid = getpid();
  char path_buffer[PROC_PIDPATHINFO_MAXSIZE];
  if(proc_pidpath(process_pid, path_buffer, sizeof(path_buffer)) < 0) { return NULL; }
  // get length of this path (up to, and including, the final separator)
  char* path_position = path_buffer;
  char* path_last_slash = path_buffer;
  while(*path_position) {
    if(*path_position == '/') { path_last_slash = path_position; }
    ++path_position;
  }
  path_last_slash[1] = 0x00;

  // create buffer with composed length
  uint32_t path_length = strlen(path_buffer) + strlen("resource/") + strlen(filename) + 1;
  char* resource_path = (char*)malloc(path_length);
  snprintf(resource_path, path_length, "%sresource/%s", path_buffer, filename);

  return resource_path;
}

void Editor::handleUiAction(uint32_t ui_action) {
  switch(ui_action) {
    case UI_ACTION_NONE: return;
    case UI_ACTION_QUIT_REQUESTED: running = false; break;
  }

  if((ui_action >= UI_ACTION_TOOL_PLACE) && (ui_action <= UI_ACTION_TOOL_INSPECT)) {
    ToolbarMain* main_toolbar = (ToolbarMain*)ui_main_toolbar;
    main_toolbar->setActiveId(ui_action);

    switch(ui_action) {
      case UI_ACTION_TOOL_PLACE:   selected_tool = EditorTool_Add;      break;
      case UI_ACTION_TOOL_ERASE:   selected_tool = EditorTool_Erase;    break;
      case UI_ACTION_TOOL_PAINT:   selected_tool = EditorTool_ColorSet; break;
      case UI_ACTION_TOOL_SELECT:  selected_tool = EditorTool_Select;   break;
      case UI_ACTION_TOOL_MOVE:    selected_tool = EditorTool_Move;     break;
      case UI_ACTION_TOOL_INSPECT: selected_tool = EditorTool_ColorGet; break;
    }
    return;
  }
}

void Editor::handleFrameSelected(const char* frame_name) {
}

void Editor::handleColorSelected(uint32_t color) {
}

void Editor::handleModalModelOpen(const char* path) {
}

void Editor::handleModalPaletteOpen(const char* path) {
}

void Editor::renderModel(bool for_selection_buffer, Shader* shader_default, SelectionBufferId* hovered_id) {
  if(!visible_voxels) { return; }

  std::vector<VxxVisibleVoxel>::iterator visible_voxel_iterator = visible_voxels->begin();
  while(visible_voxel_iterator != visible_voxels->end()) {
    VxxVoxel voxel = visible_voxel_iterator->voxel;
    uint8_t faces = visible_voxel_iterator->faces;
    Color color = raylibColorFromUint32(voxel.color);
    Vector3 position = {
      .x = ((float)voxel.x) + 0.5f,
      .y = ((float)voxel.y) + 0.5f,
      .z = ((float)voxel.z) + 0.5f,
    };
    SelectionBufferId shader_id = {
      .voxel_x = voxel.x,
      .voxel_y = voxel.y,
      .voxel_z = voxel.z,
      .voxel_face = 0,
    };
    Model* model_lookup[] = {
      &(voxel_face_models.top),
      &(voxel_face_models.bottom),
      &(voxel_face_models.left),
      &(voxel_face_models.right),
      &(voxel_face_models.front),
      &(voxel_face_models.back),
    };
    Vector3 position_offsets[] = {
      { .x=position.x  , .y=position.y+1, .z=position.z   },
      { .x=position.x  , .y=position.y-1, .z=position.z   },
      { .x=position.x-1, .y=position.y  , .z=position.z   },
      { .x=position.x+1, .y=position.y  , .z=position.z   },
      { .x=position.x  , .y=position.y  , .z=position.z+1 },
      { .x=position.x  , .y=position.y  , .z=position.z-1 },
    };
    bool hovered = false;
    if(hovered_id->voxel_face & 63) {
      if(voxel.x == hovered_id->voxel_x) {
        if(voxel.y == hovered_id->voxel_y) {
          if(voxel.z == hovered_id->voxel_z) {
            hovered = true;
          }
        }
      }
    }

    if(hovered && (selected_tool == EditorTool_ColorSet)) {
      color = raylibColorFromUint32(selected_color);
    }

    for(uint32_t idx=0; idx<6; ++idx) {
      uint32_t bit_value = (1 << idx);
      if(faces & bit_value) {
        if(for_selection_buffer) {
          shader_id.voxel_face = bit_value;
          selection_buffer.setShaderId(shader_id);
          model_lookup[idx]->materials[0].shader = selection_buffer.shader;
          DrawModel(*(model_lookup[idx]), position, 1.0f, WHITE);
        } else {
          if(selected_tool == EditorTool_Add) {
            if(hovered && hovered_id->voxel_face == bit_value) {
              Color new_color = {
                .r = (uint8_t)((selected_color & 0xFF000000) >> 24),
                .g = (uint8_t)((selected_color & 0x00FF0000) >> 16),
                .b = (uint8_t)((selected_color & 0x0000FF00) >>  8),
                .a = 0x88,
              };
              DrawCube(position_offsets[idx], 1.0f, 1.0f, 1.0f, new_color);
              DrawCubeWires(position_offsets[idx], 1.0f, 1.0f, 1.0f, new_color);
            }
          }
          model_lookup[idx]->materials[0].shader = *shader_default;
          DrawModel(*(model_lookup[idx]), position, 1.0f, color);
          DrawCubeWires(position, 1.0f, 1.0f, 1.0f, BLACK);
        }
      }
    }

    visible_voxel_iterator++;
  }
}

static bool pointWithinRectangle(float x, float y, Rectangle* rect) {
  if(x < rect->x) { return false; }
  if(y < rect->y) { return false; }
  if(x >= (rect->x + rect->width )) { return false; }
  if(y >= (rect->y + rect->height)) { return false; }
  return true;
}

void Editor::performAction(Action action) {
  std::unordered_map<std::string, ActionStack>::iterator position = frame_action_stacks.find(current_model_frame_name);
  if(position == frame_action_stacks.end()) { return; }
  ActionStack stack = position->second;

  stack.act(action);

  switch(action.type) {
    case ActionType_VoxelsAdd: {
      std::vector<VxxVoxel>::iterator iterator = action.data.voxels_after.begin();
      while(iterator != action.data.voxels_after.end()) {
        current_model_frame->addVoxel(*iterator);
        iterator++;
      }
      free((void*)visible_voxels);
      visible_voxels = current_model_frame->getVisibleVoxels();
      break;
    }

    case ActionType_VoxelsRemove: {
      std::vector<VxxVoxel>::iterator iterator = action.data.voxels_before.begin();
      while(iterator != action.data.voxels_before.end()) {
        current_model_frame->removeVoxel(iterator->x, iterator->y, iterator->z);
        iterator++;
      }
      free((void*)visible_voxels);
      visible_voxels = current_model_frame->getVisibleVoxels();
      break;
    }

    case ActionType_VoxelsModify: {
      std::vector<VxxVoxel>::iterator iterator_before = action.data.voxels_before.begin();
      std::vector<VxxVoxel>::iterator iterator_after  = action.data.voxels_after.begin();
      while(iterator_before != action.data.voxels_before.end()) {
        current_model_frame->updateVoxel(iterator_before->x, iterator_before->y, iterator_before->z, *iterator_after);
        iterator_before++;
        iterator_after++;
      }
      free((void*)visible_voxels);
      visible_voxels = current_model_frame->getVisibleVoxels();
      break;
    }
  }
}

void Editor::mainLoop() {
  SetConfigFlags(FLAG_WINDOW_RESIZABLE);
  InitWindow(800, 480, "voxxy");
  SetExitKey(0);

  const char* resource_path = pathForResource("lavector.rgs");
  GuiLoadStyle(resource_path);
  free((void*)resource_path);
  resource_path = pathForResource("charcoal.ttf");
  Font font = LoadFontEx(resource_path, 16, NULL, 0);
  GuiSetFont(font);
  free((void*)resource_path);

  const char* selection_buffer_vertex_shader_path   = pathForResource("shader/selection-buffer.vs");
  const char* selection_buffer_fragment_shader_path = pathForResource("shader/selection-buffer.fs");
  selection_buffer.initialize(selection_buffer_vertex_shader_path, selection_buffer_fragment_shader_path);
  free((void*)selection_buffer_vertex_shader_path);
  free((void*)selection_buffer_fragment_shader_path);

  Camera3D camera = {
    .position = { .x=10.0f, .y=10.0f, .z=10.0f },
    .target   = { .x= 0.0f, .y= 0.0f, .z= 0.0f },
    .up       = { .x= 0.0f, .y= 1.0f, .z= 0.0f },
    .fovy     = 60.0f,
    .projection = CAMERA_PERSPECTIVE,
  };

  SetTargetFPS(60);
  SetCameraMode(camera, CAMERA_FREE);

  Rectangle rect_screen;
  Rectangle rect_main_toolbar;
  Rectangle rect_frame_window;
  Rectangle rect_color_window;
  Rectangle rect_modal;
  int32_t screen_width_current;
  int32_t screen_height_current;
  int32_t mouse_x;
  int32_t mouse_y;
  bool mouse_over_scene = true;
  SelectionBufferId selection_id = { .voxel_x=0, .voxel_y=0, .voxel_z=0, .voxel_face=0 };

  Shader shader_default;
  {
    Mesh cube_mesh = GenMeshCube(1.0f, 1.0f, 1.0f);
    UploadMesh(&cube_mesh, false);
    Model cube_model = LoadModelFromMesh(cube_mesh);
    shader_default = cube_model.materials[0].shader;
    UnloadMesh(cube_mesh);
  }

  if(!voxel_face_models_generated) { generateVoxelFaceModels(&voxel_face_models); }

  bool selection_mouse_down = false;
  SelectionBufferId selection_mouse_down_id = { .voxel_x=0, .voxel_y=0, .voxel_z=0, .voxel_face=0 };

  while(running) {
    if(WindowShouldClose()) { handleUiAction(UI_ACTION_QUIT_REQUESTED); }
    UpdateCamera(&camera);

    screen_width_current = GetScreenWidth();
    screen_height_current = GetScreenHeight();
    if((screen_width_current != screen_width_previous) || (screen_height_current != screen_height_previous)) {
      rect_screen = { 0.0f, 0.0f, ((float)screen_width_current), ((float)screen_height_current) };
      rect_main_toolbar = { 0.0f, 0.0f, ((float)screen_width_current), (TOOLBAR_ITEM_SIZE + 2.0f) };
      selection_buffer.resize(screen_width_current, screen_height_current);

      screen_width_previous  = screen_width_current;
      screen_height_previous = screen_height_current;
    }

    mouse_x = GetMouseX();
    mouse_y = GetMouseY();

    // check if mouse over non-ui scene area
    mouse_over_scene = true;
    float mouse_xf = (float)mouse_x;
    float mouse_yf = (float)mouse_y;
    if(pointWithinRectangle(mouse_xf, mouse_yf, &rect_screen) == false) { mouse_over_scene = false; }
    if(mouse_over_scene) { if(pointWithinRectangle(mouse_xf, mouse_yf, &rect_main_toolbar)) { mouse_over_scene = false; } }

    BeginDrawing(); {
      BeginMode3D(camera); {
        selection_id.voxel_face = 0;
        if(mouse_over_scene) {
          BeginShaderMode(selection_buffer.shader);
          selection_buffer.bind();
          glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
          selection_buffer.setShaderId({ 0, 0, 0, 0 });
          renderModel(true, &shader_default, &selection_id);
          selection_buffer.unbind();
          EndShaderMode();
          selection_id = selection_buffer.readIdFromPixel(mouse_x, screen_height_current - mouse_y);
        }
        ClearBackground({ 255, 255, 255, 255 });
        DrawGrid(10, 1.0f);
        renderModel(false, &shader_default, &selection_id);
      } EndMode3D();
      
      ui_main_toolbar->render(rect_main_toolbar);
    } EndDrawing();

    // test if mouse+tool interacted with scene
    if(mouse_over_scene && selection_id.voxel_face) {
      if(selection_mouse_down == false) {
        if(IsMouseButtonPressed(MOUSE_BUTTON_LEFT)) {
          selection_mouse_down = true;
          selection_mouse_down_id = selection_id;
        }
      } else {
        if(IsMouseButtonPressed(MOUSE_BUTTON_LEFT) == false) {
          selection_mouse_down = false;
          if(selectionIdsSameVoxel(selection_mouse_down_id,selection_id)) {
            if((selected_tool != EditorTool_Add) || (selection_id.voxel_face == selection_mouse_down_id.voxel_face)) {
              switch(selected_tool) {
                case EditorTool_Add: {
                  VxxVoxel voxel_new = { .x=selection_id.voxel_x, .y=selection_id.voxel_y, .z=selection_id.voxel_z, .color=selected_color };
                  bool valid_face = false;
                  switch(selection_mouse_down_id.voxel_face) {
                    case VXX_VOXEL_FACE_TOP   : { valid_face=true; voxel_new.y++; break; }
                    case VXX_VOXEL_FACE_BOTTOM: { valid_face=true; voxel_new.y--; break; }
                    case VXX_VOXEL_FACE_LEFT  : { valid_face=true; voxel_new.x--; break; }
                    case VXX_VOXEL_FACE_RIGHT : { valid_face=true; voxel_new.x++; break; }
                    case VXX_VOXEL_FACE_FRONT : { valid_face=true; voxel_new.z++; break; }
                    case VXX_VOXEL_FACE_BACK  : { valid_face=true; voxel_new.z--; break; }
                  }
                  if(valid_face) {
                    Action action;
                    action.type = ActionType_VoxelsAdd;
                    action.data.voxels_after.push_back(voxel_new);
                    performAction(action);
                  }
                  break;
                }
                case EditorTool_Erase: {
                  VxxVoxel *voxel_old = current_model_frame->getVoxel(selection_id.voxel_x, selection_id.voxel_y, selection_id.voxel_z);
                  if(voxel_old) {
                    Action action;
                    action.type = ActionType_VoxelsRemove;
                    action.data.voxels_before.push_back(*voxel_old);
                    performAction(action);
                  }
                  break;
                }
                case EditorTool_ColorSet: {
                  VxxVoxel *voxel_old = current_model_frame->getVoxel(selection_id.voxel_x, selection_id.voxel_y, selection_id.voxel_z);
                  if(voxel_old) {
                    Action action;
                    action.type = ActionType_VoxelsModify;
                    action.data.voxels_before.push_back(*voxel_old);
                    VxxVoxel voxel_new = *voxel_old;
                    voxel_new.color = selected_color;
                    action.data.voxels_after.push_back(voxel_new);
                    performAction(action);
                  }
                  break;
                }
                case EditorTool_ColorGet: {
                  current_model_frame->getVoxelColor(selection_id.voxel_x, selection_id.voxel_y, selection_id.voxel_z, &selected_color);
                  break;
                }
              }
            }
          }
        }
      }
      
    } else {
      selection_mouse_down = false;
    }
  } // whie(running)

  CloseWindow();
}
