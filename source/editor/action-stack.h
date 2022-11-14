#import <ObjFW/ObjFW.h>
#import "../data/voxel-model.h"

typedef enum {
  ActionType_Invalid,
  ActionType_VoxelsAdded,
  ActionType_VoxelsRemoved,
  ActionType_VoxelsModified,
} ActionType;

@interface Action : OFObject {
@public
  ActionType type;
  OFArray<Voxel*>* voxels_before;
  OFArray<Voxel*>* voxels_after;
}
-(id)initWithVoxelAdded:(Voxel*)voxel;
-(id)initWithVoxelRemoved:(Voxel*)voxel; 
-(id)initWithVoxel:(Voxel*)voxel Colored:(uint32_t)new_color;
-(id)initWithVoxels:(OFArray<Voxel*>*)voxels_before andModifications:(OFArray<Voxel*>*)voxels_after;
@end

@interface ActionStack : OFObject {
  int32_t depth_maximum;
  int32_t index_saved;
  int32_t index_current;
  OFArray<Action*>* actions;
}
-(id)initWithDepth:(int32_t)depth_maximum;
-(bool)canUndo;
-(bool)canRedo;
-(bool)isStateSaved;
-(void)reset;
-(void)markStateSaved;
-(Action*)getUndoAction;
-(Action*)getRedoAction;
-(void)pushAction:(Action*)action;
@end
