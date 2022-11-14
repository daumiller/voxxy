#import "editor-state.h"

#define ACTION_STACK_DEPTH 128

// EditorInterfaceState ===========================================================================================================
@implementation EditorInterfaceState
-(id)init {
  self = [super init];
  if(!self) { return self; }

  EditorSelectionRectangle select_rect = {
    .start_x    = 0,
    .start_y    = 0,
    .current_x  = 0,
    .current_y  = 0,
    .is_started = false,
    .is_ongoing = false,
  }; 

  selected_color           = 0x888888FF;
  selected_tool            = EditorTool_VoxelAdd;
  selected_rectangle       = select_rect;
  selected_voxels          = NULL;
  active_modal             = EditorModalType_None;
  screen_width_last_frame  = -1;
  screen_height_last_frame = -1;
  ui_colors_expanded       = false;
  ui_frames_expanded       = false;
  toolbar                  = [[Toolbar alloc] initWithStyle:ToolbarStyle_Grouped];
  color_picker             = [[ColorPicker alloc] init];
  continue_main_loop       = true;

  [color_picker setColor:selected_color];

  // Model toolbar items
  [toolbar appendItemWithId:ToolbarButtonId_ModelNew  Icon:"#8#" Visible:true Enabled:true Active:false GroupEnd:false];
  [toolbar appendItemWithId:ToolbarButtonId_ModelOpen Icon:"#1#" Visible:true Enabled:true Active:false GroupEnd:false];
  [toolbar appendItemWithId:ToolbarButtonId_ModelSave Icon:"#2#" Visible:true Enabled:true Active:false GroupEnd:true ];
  // Voxel toolbar items
  [toolbar appendItemWithId:ToolbarButtonId_VoxelAdd          Icon:"#22#" Visible:true Enabled:true Active:true  GroupEnd:false];
  [toolbar appendItemWithId:ToolbarButtonId_VoxelRemove       Icon:"#28#" Visible:true Enabled:true Active:false GroupEnd:false];
  [toolbar appendItemWithId:ToolbarButtonId_VoxelColorSet     Icon:"#24#" Visible:true Enabled:true Active:false GroupEnd:false];
  [toolbar appendItemWithId:ToolbarButtonId_VoxelSelect       Icon:"#21#" Visible:true Enabled:true Active:false GroupEnd:false];
  [toolbar appendItemWithId:ToolbarButtonId_VoxelMoveSelected Icon:"#32#" Visible:true Enabled:true Active:false GroupEnd:false];
  [toolbar appendItemWithId:ToolbarButtonId_VoxelColorGet     Icon:"#27#" Visible:true Enabled:true Active:false GroupEnd:true ];
  // Settings toolbar items
  [toolbar appendItemWithId:ToolbarButtonId_Invalid      Icon:NULL    Visible:true Enabled:true Active:false GroupEnd:false];
  [toolbar appendItemWithId:ToolbarButtonId_SettingsOpen Icon:"#142#" Visible:true Enabled:true Active:false GroupEnd:false];

  [toolbar setDelegate:(id<ToolbarDelegate>)self];
  [color_picker setDelegate:(id<ColorPickerDelegate>)self];

  return self;
}
-(void)dealloc {
  if(selected_voxels) { [selected_voxels release]; }
  [toolbar release];
  [color_picker release];
  [super dealloc];
}

-(void)setColor:(uint32_t)color {
  selected_color = color;
  [color_picker setColor:color];
}

-(void)toolbarItemClicked:(ToolbarItem*)toolbar_item {
  switch(toolbar_item->id) {
    case ToolbarButtonId_VoxelAdd         : { [toolbar setSelectedItemId:toolbar_item->id]; selected_tool = EditorTool_VoxelAdd;          break; }
    case ToolbarButtonId_VoxelRemove      : { [toolbar setSelectedItemId:toolbar_item->id]; selected_tool = EditorTool_VoxelRemove;       break; }
    case ToolbarButtonId_VoxelColorSet    : { [toolbar setSelectedItemId:toolbar_item->id]; selected_tool = EditorTool_VoxelColorSet;     break; }
    case ToolbarButtonId_VoxelSelect      : { [toolbar setSelectedItemId:toolbar_item->id]; selected_tool = EditorTool_VoxelSelect;       break; }
    case ToolbarButtonId_VoxelMoveSelected: { [toolbar setSelectedItemId:toolbar_item->id]; selected_tool = EditorTool_VoxelMoveSelected; break; }
    case ToolbarButtonId_VoxelColorGet    : { [toolbar setSelectedItemId:toolbar_item->id]; selected_tool = EditorTool_VoxelColorGet;     break; }

    case ToolbarButtonId_Invalid     : break;
    case ToolbarButtonId_ModelNew    : break;
    case ToolbarButtonId_ModelOpen   : break;
    case ToolbarButtonId_ModelSave   : break;
    case ToolbarButtonId_SettingsOpen: break;
  }
}

-(void)colorChanged:(uint32_t)color {
  selected_color = color;
}
@end

// EditorDataState ================================================================================================================
@implementation EditorDataState
-(id)init {
  self = [super init];
  if(!self) { return self; }

  current_model       = NULL;
  current_frame       = NULL;
  current_model_path  = NULL;
  current_frame_name  = NULL;
  visible_voxels      = NULL;
  frame_action_stacks = NULL;
  return self;
}

-(void)cleanup {
  if(frame_action_stacks) { [frame_action_stacks release]; frame_action_stacks = NULL; }
  if(visible_voxels     ) { [visible_voxels      release]; visible_voxels      = NULL; }
  if(current_frame_name ) { [current_frame_name  release]; current_frame_name  = NULL; }
  if(current_model_path ) { [current_model_path  release]; current_model_path  = NULL; }
  if(current_model      ) { [current_model       release]; current_model       = NULL; }
  current_frame = NULL;
}

-(void)dealloc {
  [self cleanup];
  [super dealloc];
}

-(void)loadNewModel {
  [self cleanup];
  current_model_path = NULL;
  current_frame_name = [[OFString alloc] initWithCString:"default" encoding:OFStringEncodingUTF8];

  current_model = [[VoxelModelEditor alloc] init];
  current_frame = [[VoxelModelFrameEditor alloc] init];
  [current_frame addVoxelX:0 Y:0 Z:0 Color:0xBB0022FF];
  [current_model addFrame:current_frame withName:"default"];
  [current_frame release];

  visible_voxels = [current_frame getVisibleVoxels];
  ActionStack* action_stack_default = [[ActionStack alloc] initWithDepth:ACTION_STACK_DEPTH];
  frame_action_stacks = [[OFMutableDictionary<OFString*, ActionStack*> alloc] init];
  [frame_action_stacks setObject:action_stack_default forKey:current_frame_name];
}
//-(bool)loadModelFile:(OFString*)path;
//-(bool)saveModel;
//-(bool)saveModelAs:(OFString*)path;
//-(bool)addFrameNamed:(OFString*)frame_name;
//-(bool)removeFrameNamed:(OFString*)frame_name;

-(ActionStack*)getCurrentActionStack {
  if(!current_frame_name ) { return NULL; }
  if(!frame_action_stacks) { return NULL; }
  return [frame_action_stacks objectForKey:current_frame_name];
}

-(bool)canUndo {
  ActionStack* current_action_stack = [self getCurrentActionStack];
  if(!current_action_stack) { return false; }
  return [current_action_stack canUndo];
}

-(bool)canRedo {
  ActionStack* current_action_stack = [self getCurrentActionStack];
  if(!current_action_stack) { return false; }
  return [current_action_stack canRedo];
}

-(bool)hasUnsavedChanges {
  if(!frame_action_stacks) { return false; }
  bool any_unsaved_frames = false;
  for(id key in frame_action_stacks) {
    ActionStack* current_stack = [frame_action_stacks objectForKey:key];
    if([current_stack isStateSaved] == false) { any_unsaved_frames = true; break; }
  }
  return any_unsaved_frames;
}

-(void)performAction:(Action*)action {
  size_t voxels_after_count  = [action->voxels_after  count];
  size_t voxels_before_count = [action->voxels_before count]; 
  switch(action->type) {
    case ActionType_Invalid: break;
    case ActionType_VoxelsAdded: {
      for(size_t idx=0; idx<voxels_after_count; ++idx) { [current_frame addVoxel:[action->voxels_after objectAtIndex:idx]]; }
      break;
    }
    case ActionType_VoxelsRemoved: {
      for(size_t idx=0; idx<voxels_before_count; ++idx) { [current_frame removeVoxel:[action->voxels_before objectAtIndex:idx]]; }
      break;
    }
    case ActionType_VoxelsModified: {
      if(voxels_before_count != voxels_after_count) { break; } // THIS SHOULD NOT HAPPEN
      for(size_t idx=0; idx<voxels_after_count; ++idx) {
        Voxel* voxel_before = [action->voxels_before objectAtIndex:idx];
        Voxel* voxel_after  = [action->voxels_after  objectAtIndex:idx];
        [current_frame updateVoxel:voxel_before withVoxel:voxel_after];
      }
      break;
    }
  }
  if(visible_voxels) { [visible_voxels release]; }
  visible_voxels = [current_frame getVisibleVoxels];
}

-(void)unperformAction:(Action*)action {
  size_t voxels_after_count  = [action->voxels_after  count];
  size_t voxels_before_count = [action->voxels_before count]; 
  switch(action->type) {
    case ActionType_Invalid: break;
    case ActionType_VoxelsAdded: {
      for(size_t idx=0; idx<voxels_after_count; ++idx) { [current_frame removeVoxel:[action->voxels_after objectAtIndex:idx]]; }
      break;
    }
    case ActionType_VoxelsRemoved: {
      for(size_t idx=0; idx<voxels_before_count; ++idx) { [current_frame addVoxel:[action->voxels_before objectAtIndex:idx]]; }
      break;
    }
    case ActionType_VoxelsModified: {
      if(voxels_before_count != voxels_after_count) { break; } // THIS SHOULD NOT HAPPEN
      for(size_t idx=0; idx<voxels_after_count; ++idx) {
        Voxel* voxel_before = [action->voxels_before objectAtIndex:idx];
        Voxel* voxel_after  = [action->voxels_after  objectAtIndex:idx];
        [current_frame updateVoxel:voxel_after withVoxel:voxel_before];
      }
      break;
    }
  }
  if(visible_voxels) { [visible_voxels release]; }
  visible_voxels = [current_frame getVisibleVoxels];
}

-(bool)undo {
  ActionStack* current_stack = [self getCurrentActionStack];
  if(!current_stack          ) { return false; }
  if(![current_stack canUndo]) { return false; }
  Action* action = [current_stack getUndoAction];
  [self unperformAction:action];
  return true;
}

-(bool)redo {
  ActionStack* current_stack = [self getCurrentActionStack];
  if(!current_stack          ) { return false; }
  if(![current_stack canRedo]) { return false; }
  Action* action = [current_stack getRedoAction];
  [self performAction:action];
  return true;
}

-(bool)voxelAddX:(int32_t)x Y:(int32_t)y Z:(int32_t)z Color:(uint32_t)color {
  ActionStack* current_stack = [self getCurrentActionStack];
  if(!current_stack) { return false; }
  if(!current_frame) { return false; }

  bool result = [current_frame addVoxelX:x Y:y Z:z Color:color];
  if(!result) { return false; }

  Voxel* added_voxel = [current_frame lookupVoxelX:x Y:y Z:z];
  Action* action = [[Action alloc] initWithVoxelAdded:added_voxel];
  [current_stack pushAction:action];

  [action release];

  if(visible_voxels) { [visible_voxels release]; }
  visible_voxels = [current_frame getVisibleVoxels];
  return true;
}

-(bool)voxelRemoveX:(int32_t)x Y:(int32_t)y Z:(int32_t)z {
  ActionStack* current_stack = [self getCurrentActionStack];
  if(!current_stack) { return false; }
  if(!current_frame) { return false; }

  Voxel* removed_voxel = [current_frame lookupVoxelX:x Y:y Z:z];
  if(!removed_voxel) { return false; }

  [removed_voxel retain];
  bool result = [current_frame removeVoxel:removed_voxel];
  if(!result) { [removed_voxel release]; return false; }

  Action* action = [[Action alloc] initWithVoxelRemoved:removed_voxel];
  [current_stack pushAction:action];

  [removed_voxel release];
  [action release];

  if(visible_voxels) { [visible_voxels release]; }
  visible_voxels = [current_frame getVisibleVoxels];
  return true;
}

-(bool)voxelColorX:(int32_t)x Y:(int32_t)y Z:(int32_t)z Color:(uint32_t)color {
  ActionStack* current_stack = [self getCurrentActionStack];
  if(!current_stack) { return false; }
  if(!current_frame) { return false; }

  Voxel* colored_voxel = [current_frame lookupVoxelX:x Y:y Z:z];
  if(!colored_voxel) { return false; }

  bool result = [current_frame setVoxel:colored_voxel Color:color];
  if(!result) { return false; }

  Action* action = [[Action alloc] initWithVoxel:colored_voxel Colored:color];
  [current_stack pushAction:action];

  [action release];

  if(visible_voxels) { [visible_voxels release]; }
  visible_voxels = [current_frame getVisibleVoxels];
  return true;
}

-(bool)translateVoxels:(OFArray<Voxel*>*)voxels byX:(int32_t)translate_x Y:(int32_t)translate_y Z:(int32_t)translate_z {
  ActionStack* current_stack = [self getCurrentActionStack];
  if(!current_stack) { return false; }
  if(!current_frame) { return false; }

  OFMutableArray<Voxel*>* updated_voxels = [[OFMutableArray alloc] init];
  size_t voxel_count = [voxels count];
  for(size_t idx=0; idx<voxel_count; ++idx) {
    Voxel* current_original = [voxels objectAtIndex:idx];
    Voxel* current_updated  = [[Voxel alloc] init];
    current_updated->x          = current_original->x + translate_x;
    current_updated->y          = current_original->y + translate_y;
    current_updated->z          = current_original->z + translate_z;
    current_updated->color      = current_original->color;
    current_updated->reserved_1 = current_original->reserved_1;
    current_updated->reserved_2 = current_original->reserved_2;
    current_updated->reserved_3 = current_original->reserved_3;
    current_updated->reserved_4 = current_original->reserved_4;

    [current_frame moveVoxel:current_original toX:current_updated->x Y:current_updated->y Z:current_updated->z];
    [updated_voxels addObject:current_updated];
    [current_updated release];
  }

  Action* action = [[Action alloc] initWithVoxels:voxels andModifications:updated_voxels];
  [current_stack pushAction:action];
  [updated_voxels release];
  [action release];

  if(visible_voxels) { [visible_voxels release]; }
  visible_voxels = [current_frame getVisibleVoxels];
  return true;
}

-(uint32_t)voxelGetColorX:(int32_t)x Y:(int32_t)y Z:(int32_t)z {
  if(!current_frame) { return 0x00000000; }
  Voxel* voxel = [current_frame lookupVoxelX:x Y:y Z:z];
  if(!voxel) { return 0x00000000; }
  return voxel->color;
}

@end
