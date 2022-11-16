#import "editor.h"
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <libproc.h>
#include <raylib.h>
#include <raygui.h>

// TODO: ifdef these by platform, or store (all keyboard shortcuts) in settings...
#define SHORTCUT_KEY_LEFT  KEY_LEFT_SUPER
#define SHORTCUT_KEY_RIGHT KEY_RIGHT_SUPER

// Helpers ========================================================================================================================
static const char* pathForResource(const char* filename) {
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
  uint32_t path_length = (uint32_t)(strlen(path_buffer) + strlen("resource/") + strlen(filename) + 1);
  char* resource_path = (char*)malloc(path_length);
  snprintf(resource_path, path_length, "%sresource/%s", path_buffer, filename);

  return resource_path;
}

static inline Color raylibColorFromUint32(uint32_t uint32_color) {
    return (Color){
      .r = (uint8_t)((uint32_color & 0xFF000000) >> 24),
      .g = (uint8_t)((uint32_color & 0x00FF0000) >> 16),
      .b = (uint8_t)((uint32_color & 0x0000FF00) >>  8),
      .a = (uint8_t)((uint32_color & 0x000000FF) >>  0),
    };
}

static bool pointWithinRectangle(float x, float y, Rectangle* rect) {
  if(x < rect->x) { return false; }
  if(y < rect->y) { return false; }
  if(x >= (rect->x + rect->width )) { return false; }
  if(y >= (rect->y + rect->height)) { return false; }
  return true;
}

// Editor =========================================================================================================================
@implementation Editor
-(id)init {
  self = [super init];
  if(!self) { return self; }

  state_of_interface = [[EditorInterfaceState alloc] init];
  state_of_data      = [[EditorDataState      alloc] init];
  voxel_face_models  = NULL;
  selection_buffer   = NULL;

  [state_of_data loadNewModel];
  return self;
}

-(void)dealloc {
  if(state_of_interface) { [state_of_interface release]; }
  if(state_of_data     ) { [state_of_data      release]; }
  if(voxel_face_models ) { [voxel_face_models  release]; }
  if(selection_buffer  ) { [selection_buffer   release]; }
  [super dealloc];
}

-(void)renderModelForSelectionBuffer:(bool)for_selection_buffer withDefaultShader:(Shader*)shader_default andHoveredSelection:(SelectionBufferId*)hovered_id{
  if(!state_of_data->visible_voxels) { return; }

  size_t visible_voxel_count = [state_of_data->visible_voxels count];
  for(uint32_t visible_voxel_index=0; visible_voxel_index<visible_voxel_count; ++visible_voxel_index) {
    VisibleVoxel* visible_voxel = [state_of_data->visible_voxels objectAtIndex:visible_voxel_index];
    Voxel*  voxel = visible_voxel->voxel;
    uint8_t faces = visible_voxel->faces;
    Color color = raylibColorFromUint32(voxel->color);
    Vector3 position = (Vector3){
      .x = ((float)voxel->x) + 0.5f,
      .y = ((float)voxel->y) + 0.5f,
      .z = ((float)voxel->z) + 0.5f,
    };
    SelectionBufferId shader_id = (SelectionBufferId){
      .voxel_x = voxel->x,
      .voxel_y = voxel->y,
      .voxel_z = voxel->z,
      .voxel_face = 0,
    };
    Vector3 position_offsets[] = {
      (Vector3){ .x=position.x  , .y=position.y+1, .z=position.z   },
      (Vector3){ .x=position.x  , .y=position.y-1, .z=position.z   },
      (Vector3){ .x=position.x-1, .y=position.y  , .z=position.z   },
      (Vector3){ .x=position.x+1, .y=position.y  , .z=position.z   },
      (Vector3){ .x=position.x  , .y=position.y  , .z=position.z+1 },
      (Vector3){ .x=position.x  , .y=position.y  , .z=position.z-1 },
    };
    bool hovered = false;
    if(hovered_id->voxel_face & 63) {
      if(voxel->x == hovered_id->voxel_x) { if(voxel->y == hovered_id->voxel_y) { if(voxel->z == hovered_id->voxel_z) { hovered = true; } } }
    }
    if(hovered && (state_of_interface->selected_tool == EditorTool_VoxelColorSet)) {
      color = raylibColorFromUint32(state_of_interface->selected_color);
    }

    for(uint32_t idx=0; idx<6; ++idx) {
      uint32_t bit_value = (1 << idx);
      if((faces & bit_value) == 0) { continue; }

      Model* face_model = [voxel_face_models modelForFace:bit_value];
      if(for_selection_buffer) {
        shader_id.voxel_face = bit_value;
        [selection_buffer setShaderId:shader_id];
        face_model->materials[0].shader = selection_buffer->shader;
        DrawModel(*face_model, position, 1.0f, WHITE);
      } else {
        if((state_of_interface->selected_tool == EditorTool_VoxelAdd) && hovered && (hovered_id->voxel_face == bit_value)) {
          Color new_color = raylibColorFromUint32(state_of_interface->selected_color); new_color.a = 0x88;
          DrawCube(position_offsets[idx], 1.0f, 1.0f, 1.0f, new_color);
          DrawCubeWires(position_offsets[idx], 1.0f, 1.0f, 1.0f, BLACK);
        }
        face_model->materials[0].shader = *shader_default;
        DrawModel(*face_model, position, 1.0f, color);
        DrawCubeWires(position, 1.0f, 1.0f, 1.0f, BLACK);
      }
    } // for(uint32_t idx=0; idx<6; ++idx)
  } // for(uint32_t visible_voxel_index=0; visible_voxel_index<visible_voxel_count; ++visible_voxel_index)
  BoundingBox box = {
    .min={
      .x=(float)(state_of_data->bounding_box.minimum.x),
      .y=(float)(state_of_data->bounding_box.minimum.y),
      .z=(float)(state_of_data->bounding_box.minimum.z),
    },
    .max={
      .x=(float)(state_of_data->bounding_box.maximum.x)+1.0f,
      .y=(float)(state_of_data->bounding_box.maximum.y)+1.0f,
      .z=(float)(state_of_data->bounding_box.maximum.z)+1.0f,
    },
  };
  DrawBoundingBox(box, GRAY);
}

typedef struct {
  int32_t x;
  int32_t y;
  float xf;
  float yf;
  bool is_over_scene;
  bool was_pressed_over_scene;
  bool was_pressed_over_valid_face;
  SelectionBufferId pressed_id;
  SelectionBufferId hovered_id;
} MouseState;

-(void)processSceneMouseEvents:(MouseState*)mouse_state {
  // Over Scene?
  if(mouse_state->is_over_scene == false) {
    mouse_state->was_pressed_over_scene      = false;
    mouse_state->was_pressed_over_valid_face = false;
    return;
  }

  // Over Valid Face?
  bool is_hovered_over_valid_face = VOXEL_FACE_VALID(mouse_state->hovered_id.voxel_face);
  bool was_pressed_and_released_over_scene      = false;
  bool was_pressed_and_released_over_same_voxel = false;
  bool was_pressed_and_released_over_same_face  = false;
  bool is_left_mouse_down                       = IsMouseButtonDown(MOUSE_BUTTON_LEFT);

  if(is_left_mouse_down) {
    // Was Pressed?
    if(mouse_state->was_pressed_over_scene == false) {
      mouse_state->was_pressed_over_scene      = true;
      mouse_state->was_pressed_over_valid_face = is_hovered_over_valid_face;
      if(is_hovered_over_valid_face) {
        mouse_state->pressed_id = mouse_state->hovered_id;
      } else {
        mouse_state->pressed_id.voxel_face = 0;
      }
    }
  } else {
    // Was Released?
    if(mouse_state->was_pressed_over_scene) {
      was_pressed_and_released_over_scene = true;
      mouse_state->was_pressed_over_scene = false;
    }
    if(mouse_state->was_pressed_over_valid_face) {
      was_pressed_and_released_over_same_voxel = is_hovered_over_valid_face && selectionBufferIds_sameVoxel(&(mouse_state->pressed_id), &(mouse_state->hovered_id));
      was_pressed_and_released_over_same_face  = was_pressed_and_released_over_same_voxel && (mouse_state->pressed_id.voxel_face == mouse_state->hovered_id.voxel_face);
      mouse_state->was_pressed_over_valid_face = false;
    }
  }

  switch(state_of_interface->selected_tool) {
    case EditorTool_VoxelAdd: {
      if(!was_pressed_and_released_over_same_face) { break; }
      switch(mouse_state->pressed_id.voxel_face) {
        case VOXEL_FACE_TOP   : mouse_state->pressed_id.voxel_y += 1; break;
        case VOXEL_FACE_BOTTOM: mouse_state->pressed_id.voxel_y -= 1; break;
        case VOXEL_FACE_LEFT  : mouse_state->pressed_id.voxel_x -= 1; break;
        case VOXEL_FACE_RIGHT : mouse_state->pressed_id.voxel_x += 1; break;
        case VOXEL_FACE_FRONT : mouse_state->pressed_id.voxel_z += 1; break;
        case VOXEL_FACE_BACK  : mouse_state->pressed_id.voxel_z -= 1; break;
      }
      [state_of_data voxelAddX:mouse_state->pressed_id.voxel_x Y:mouse_state->pressed_id.voxel_y Z:mouse_state->pressed_id.voxel_z Color:state_of_interface->selected_color];
      break;
    }

    case EditorTool_VoxelRemove: {
      if(!was_pressed_and_released_over_same_voxel) { break; }
      [state_of_data voxelRemoveX:mouse_state->hovered_id.voxel_x Y:mouse_state->hovered_id.voxel_y Z:mouse_state->hovered_id.voxel_z];
      break;
    }

    case EditorTool_VoxelColorSet: {
      if(!is_left_mouse_down        ) { break; }
      if(!is_hovered_over_valid_face) { break; }
      [state_of_data voxelColorX:mouse_state->hovered_id.voxel_x Y:mouse_state->hovered_id.voxel_y Z:mouse_state->hovered_id.voxel_z Color:state_of_interface->selected_color];
      break;
    }

    case EditorTool_VoxelColorGet: {
      if(!is_left_mouse_down        ) { break; }
      if(!is_hovered_over_valid_face) { break; }
      [state_of_interface setColor:[state_of_data voxelGetColorX:mouse_state->hovered_id.voxel_x Y:mouse_state->hovered_id.voxel_y Z:mouse_state->hovered_id.voxel_z]];
      break;
    }

    case EditorTool_VoxelSelect:       break; // TODO
    case EditorTool_VoxelMoveSelected: break; // TODO
  }
}

-(void)prepareForLoop {
  SetConfigFlags(FLAG_WINDOW_RESIZABLE | FLAG_MSAA_4X_HINT);
  InitWindow(800, 480, "voxxy");
  SetExitKey(0);

  const char* resource_path = pathForResource("lavector.rgs");
  GuiLoadStyle(resource_path);
  free((void*)resource_path);

  resource_path = pathForResource("charcoal.ttf");
  GuiSetFont(LoadFontEx(resource_path, 16, NULL, 0));
  free((void*)resource_path);

  const char* selection_buffer_vertex_shader_path   = pathForResource("shader/selection-buffer.vs");
  const char* selection_buffer_fragment_shader_path = pathForResource("shader/selection-buffer.fs");
  selection_buffer = [[SelectionBuffer alloc] initWithShaderVertex:selection_buffer_vertex_shader_path Fragment:selection_buffer_fragment_shader_path];
  free((void*)selection_buffer_vertex_shader_path);
  free((void*)selection_buffer_fragment_shader_path);

  voxel_face_models = [[VoxelFaceModels alloc] init];
  SetTargetFPS(60);
}

-(void)loop {
  [self prepareForLoop];

  // camera
  Camera3D camera = {
    .position = { .x=10.0f, .y=10.0f, .z=10.0f },
    .target   = { .x= 0.0f, .y= 0.0f, .z= 0.0f },
    .up       = { .x= 0.0f, .y= 1.0f, .z= 0.0f },
    .fovy     = 60.0f,
    .projection = CAMERA_PERSPECTIVE,
  };
  SetCameraMode(camera, CAMERA_FREE);

  // drawing rectangles, and other loop variables
  Rectangle draw_rect_screen        = { 0.0f, 0.0f, 0.0f, 0.0f };
  Rectangle draw_rect_toolbar       = { 0.0f, 0.0f, 0.0f, 0.0f };
  Rectangle draw_rect_colors_toggle = { 0.0f, 0.0f, 0.0f, 0.0f };
  Rectangle draw_rect_colors        = { 0.0f, 0.0f, 0.0f, 0.0f };
  Rectangle draw_rect_frames_toggle = { 0.0f, 0.0f, 0.0f, 0.0f };
  Rectangle draw_rect_frames        = { 0.0f, 0.0f, 0.0f, 0.0f };
  Rectangle draw_rect_modal         = { 0.0f, 0.0f, 0.0f, 0.0f };
  int32_t screen_width_current      = -1;
  int32_t screen_height_current     = -1;
  int wait_for_key_release          = 0;
  MouseState mouse_state = {
    .x=0, .y=0, .xf=0.0f, .yf=0.0f,
    .is_over_scene=false,
    .was_pressed_over_scene=false,
    .was_pressed_over_valid_face=false,
    .pressed_id=(SelectionBufferId){ .voxel_x=0, .voxel_y=0, .voxel_z=0, .voxel_face=0 },
    .hovered_id=(SelectionBufferId){ .voxel_x=0, .voxel_y=0, .voxel_z=0, .voxel_face=0 },
  };

  // default shader
  Shader shader_default;
  {
    Mesh cube_mesh = GenMeshCube(1.0f, 1.0f, 1.0f);
    UploadMesh(&cube_mesh, false);
    Model cube_model = LoadModelFromMesh(cube_mesh);
    shader_default = cube_model.materials[0].shader;
    UnloadModel(cube_model);
  }

  // MAIN LOOP
  while(state_of_interface->continue_main_loop) {
    if(WindowShouldClose()) { break; } // TODO:
    UpdateCamera(&camera);

    // screen size / drawing rectangles
    screen_width_current  = GetScreenWidth();
    screen_height_current = GetScreenHeight();
    if((screen_width_current < 64.0f) || (screen_height_current < 64.0f)) { continue; }
    if((screen_width_current != state_of_interface->screen_width_last_frame) || (screen_height_current != state_of_interface->screen_height_last_frame)) {
      draw_rect_screen  = (Rectangle){ 0.0f, 0.0f, ((float)screen_width_current), ((float)screen_height_current) };
      draw_rect_toolbar = (Rectangle){ 0.0f, 0.0f, draw_rect_screen.width, (TOOLBAR_ITEM_SIZE + 2.0f) };
      draw_rect_colors_toggle = (Rectangle){ ((float)screen_width_current - 192.0f), draw_rect_toolbar.height, 192.0f, 24.0f };
      draw_rect_colors = (Rectangle){ draw_rect_colors_toggle.x, draw_rect_colors_toggle.y + 24.0f, 192.0f, (float)screen_height_current - (draw_rect_colors_toggle.y + 24.0f) };
      draw_rect_frames_toggle = (Rectangle){ 0.0f, draw_rect_toolbar.height, 192.0f, 24.0f };
      draw_rect_frames = (Rectangle){ draw_rect_frames_toggle.x, draw_rect_frames_toggle.y + 24.0f, 192.0f, (float)screen_height_current - (draw_rect_frames_toggle.y + 24.0f) };
      draw_rect_modal = (Rectangle){ (float)(screen_width_current >> 2), (float)(screen_height_current >> 2), (float)(screen_width_current >> 1), (float)(screen_height_current >> 1) };
      [selection_buffer resizeWidth:screen_width_current Height:screen_height_current];
      state_of_interface->screen_width_last_frame  = screen_width_current;
      state_of_interface->screen_height_last_frame = screen_height_current; 
    }

    // mouse position / determine if over-scene (else, off-screen or over-ui)
    mouse_state.x=GetMouseX(); mouse_state.xf=(float)mouse_state.x;
    mouse_state.y=GetMouseY(); mouse_state.yf=(float)mouse_state.y;
    mouse_state.is_over_scene = true;
    if(pointWithinRectangle(mouse_state.xf, mouse_state.yf, &draw_rect_screen) == false) { mouse_state.is_over_scene = false; }
    if(mouse_state.is_over_scene) { if(pointWithinRectangle(mouse_state.xf, mouse_state.yf, &draw_rect_toolbar      )) { mouse_state.is_over_scene = false; } }
    if(mouse_state.is_over_scene) { if(pointWithinRectangle(mouse_state.xf, mouse_state.yf, &draw_rect_colors_toggle)) { mouse_state.is_over_scene = false; } }
    if(mouse_state.is_over_scene) { if(pointWithinRectangle(mouse_state.xf, mouse_state.yf, &draw_rect_frames_toggle)) { mouse_state.is_over_scene = false; } }
    if(mouse_state.is_over_scene) { if(state_of_interface->ui_colors_expanded && pointWithinRectangle(mouse_state.xf, mouse_state.yf, &draw_rect_colors)) { mouse_state.is_over_scene = false; } }
    if(mouse_state.is_over_scene) { if(state_of_interface->ui_frames_expanded && pointWithinRectangle(mouse_state.xf, mouse_state.yf, &draw_rect_frames)) { mouse_state.is_over_scene = false; } }

    // render scene: 3D Objects and UI
    BeginDrawing(); {
      BeginMode3D(camera); {
        mouse_state.hovered_id.voxel_face = 0;
        if(mouse_state.is_over_scene) {
          [selection_buffer bind];
          glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
          [selection_buffer setShaderIdX:0 Y:0 Z:0 Face:0];
          [self renderModelForSelectionBuffer:true withDefaultShader:&shader_default andHoveredSelection:&(mouse_state.hovered_id)];
          [selection_buffer unbind];
          mouse_state.hovered_id = [selection_buffer readIdFromPixelX:mouse_state.x Y:(screen_height_current - mouse_state.y)];
        }
        ClearBackground((Color){ 255, 255, 255, 255 });
        DrawGrid(10, 1.0f);
        [self renderModelForSelectionBuffer:false withDefaultShader:&shader_default andHoveredSelection:&(mouse_state.hovered_id)];
      } EndMode3D();
      
      [state_of_interface->toolbar renderInRectangle:draw_rect_toolbar];
      if(GuiButton(draw_rect_frames_toggle, "Frames")) { state_of_interface->ui_frames_expanded = !state_of_interface->ui_frames_expanded; }
      if(GuiButton(draw_rect_colors_toggle, "Colors")) { state_of_interface->ui_colors_expanded = !state_of_interface->ui_colors_expanded; }
      if(state_of_interface->ui_colors_expanded) { [state_of_interface->color_picker renderInRectangle:draw_rect_colors]; }
    } EndDrawing();

    // Mouse Events
    [self processSceneMouseEvents:&mouse_state];

    // Keyboard Events
    bool check_key_events = true;
    if(wait_for_key_release) {
      if(IsKeyDown(wait_for_key_release)) {
        check_key_events = false;
      } else {  
        wait_for_key_release = 0;
      }
    }
    if(check_key_events) {
      if(IsKeyDown(SHORTCUT_KEY_LEFT) || IsKeyDown(SHORTCUT_KEY_RIGHT)) {
        if(IsKeyDown(KEY_Z)) {
          wait_for_key_release = KEY_Z;
          if(IsKeyDown(KEY_LEFT_SHIFT) || IsKeyDown(KEY_RIGHT_SHIFT)) {
            [state_of_data redo];
          } else {
            [state_of_data undo];
          }
        } // IsKeyDown(KEY_Z)
      } // if(IsKeyDown(SHORTCUT_KEY_LEFT) || IsKeyDown(SHORTCUT_KEY_RIGHT))
    } // if(check_key_events)

  } // while(state_of_interface->continue_main_loop)

  GuiLoadStyleDefault();
  CloseWindow();
}
@end
