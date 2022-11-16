#include <stdint.h>
#include <stdbool.h>
#import <ObjFW/ObjFW.h>
#import "../interface/toolbar.h"
#import "../interface/color-picker.h"
#import "../data/voxel-model.h"
#import "../data/voxel-model-editor.h"
#import "action-stack.h"

typedef enum {
  ToolbarButtonId_Invalid = 0,
  ToolbarButtonId_ModelNew,
  ToolbarButtonId_ModelOpen,
  ToolbarButtonId_ModelSave,
  ToolbarButtonId_VoxelAdd,
  ToolbarButtonId_VoxelRemove,
  ToolbarButtonId_VoxelColorSet,
  ToolbarButtonId_VoxelSelect,
  ToolbarButtonId_VoxelMoveSelected,
  ToolbarButtonId_VoxelColorGet,
  ToolbarButtonId_SettingsOpen,
} ToolbarButtonId;

typedef enum {
  EditorTool_VoxelAdd,
  EditorTool_VoxelRemove,
  EditorTool_VoxelColorSet,
  EditorTool_VoxelColorGet,
  EditorTool_VoxelSelect,
  EditorTool_VoxelMoveSelected,
} EditorTool;

typedef struct {
  uint32_t start_x;
  uint32_t start_y;
  uint32_t current_x;
  uint32_t current_y;
  bool     is_started;
  bool     is_ongoing;
} EditorSelectionRectangle;

typedef enum {
  EditorModalType_None,
  EditorModalType_ModelOpen,
  EditorModalType_ModelSaveAs,
  EditorModalType_ModelSaveBeforeUnloading,
  EditorModalType_Settings,
} EditorModalType;

@interface EditorInterfaceState <ToolbarDelegate, ColorPickerDelegate> : OFObject {
@public
  uint32_t                 selected_color;
  EditorTool               selected_tool;
  EditorSelectionRectangle selected_rectangle;
  OFMutableArray<Voxel*>*  selected_voxels;
  EditorModalType          active_modal;
  int32_t                  screen_width_last_frame;
  int32_t                  screen_height_last_frame;
  bool                     ui_colors_expanded;
  bool                     ui_frames_expanded;
  Toolbar*                 toolbar;
  ColorPicker*             color_picker;
  bool                     continue_main_loop;
}
-(void)setColor:(uint32_t)color;
@end

@interface EditorDataState : OFObject {
@public
  VoxelModelEditor*       current_model;
  VoxelModelFrameEditor*  current_frame;
  OFString*               current_model_path;
  OFString*               current_frame_name;
  OFArray<VisibleVoxel*>* visible_voxels;
  Bounds3Di               bounding_box;
  OFMutableDictionary<OFString*, ActionStack*>* frame_action_stacks;
}
-(void)loadNewModel;
//-(bool)loadModelFile:(OFString*)path;
//-(bool)saveModel;
//-(bool)saveModelAs:(OFString*)path;
//-(bool)addFrameNamed:(OFString*)frame_name;
//-(bool)removeFrameNamed:(OFString*)frame_name;

-(bool)canUndo;
-(bool)canRedo;
-(bool)hasUnsavedChanges;
-(bool)undo;
-(bool)redo;
-(bool)voxelAddX:(int32_t)x Y:(int32_t)y Z:(int32_t)z Color:(uint32_t)color;
-(bool)voxelRemoveX:(int32_t)x Y:(int32_t)y Z:(int32_t)z;
-(bool)voxelColorX:(int32_t)x Y:(int32_t)y Z:(int32_t)z Color:(uint32_t)color;
-(bool)translateVoxels:(OFArray<Voxel*>*)voxels byX:(int32_t)translate_x Y:(int32_t)translate_y Z:(int32_t)translate_z;
-(uint32_t)voxelGetColorX:(int32_t)x Y:(int32_t)y Z:(int32_t)z;
@end
