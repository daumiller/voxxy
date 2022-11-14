#import "action-stack.h"

// index_current is the index of the just-performed action; so,
//    (index_current == -1) => no actions have been performed
//    (index_current == 0)  => action at index 0 was just performed
// index_saved is the index of which action was performed just before saving
//    (index_saved == -1) => never been saved (or saved in some pushed-out-by-overflow action)
//    (index_saved == 0) => state was saved immediately after performing the first action

// Action =========================================================================================================================
@implementation Action
-(id)initWithVoxelAdded:(Voxel*)voxel {
  self = [super init];
  if(!self) { return self; }

  type = ActionType_VoxelsAdded;
  voxels_before = [[OFArray<Voxel*> alloc] init];
  voxels_after  = [[OFMutableArray<Voxel*> alloc] initWithCapacity:1];
  [(OFMutableArray<Voxel*>*)voxels_after addObject:voxel];
  return self;
}

-(id)initWithVoxelRemoved:(Voxel*)voxel {
  self = [super init];
  if(!self) { return self; }

  type = ActionType_VoxelsRemoved;
  voxels_before = [[OFMutableArray<Voxel*> alloc] initWithCapacity:1];
  voxels_after  = [[OFArray<Voxel*> alloc] init];
  [(OFMutableArray<Voxel*>*)voxels_before addObject:voxel];
  return self;
}
 
-(id)initWithVoxel:(Voxel*)voxel_before andModification:(Voxel*)voxel_after {
  self = [super init];
  if(!self) { return self; }

  type = ActionType_VoxelsModified;
  voxels_before = [[OFMutableArray<Voxel*> alloc] initWithCapacity:1];
  voxels_after  = [[OFMutableArray<Voxel*> alloc] initWithCapacity:1];
  [(OFMutableArray<Voxel*>*)voxels_before addObject:voxel_before];
  [(OFMutableArray<Voxel*>*)voxels_after  addObject:voxel_after];
  return self;
}

-(id)initWithVoxels:(OFArray<Voxel*>*)voxels_before andModifications:(OFArray<Voxel*>*)voxels_after {
  self = [super init];
  if(!self) { return self; }

  type = ActionType_VoxelsModified;
  self->voxels_before = voxels_before;
  self->voxels_after  = voxels_after;

  [self->voxels_before retain];
  [self->voxels_after  retain];
  return self;
}

-(void)dealloc {
  [voxels_before release];
  [voxels_after  release];
  [super dealloc];
}
@end

// ActionStack ====================================================================================================================
@implementation ActionStack
-(id)initWithDepth:(int32_t)depth_maximum {
  self = [super init];
  if(!self) { return self; }

  actions = NULL;
  self->depth_maximum = depth_maximum;
  [self reset];
  return self;
}

-(void)dealloc {
  if(actions) { [actions release]; }
  [super dealloc];
}

-(int32_t)signedSize  { return (int32_t)([actions count]);                }
-(bool)canUndo        { return (index_current > -1);                      }
-(bool)canRedo        { return (index_current < ([self signedSize] - 1)); }
-(bool)isStateSaved   { return (index_current == index_saved);            }
-(void)markStateSaved { index_saved = index_current;                      } 

-(void)reset {
  if(actions) { [actions release]; }
  actions = [[OFMutableArray<Action*> alloc] initWithCapacity:depth_maximum];
  index_saved   = -2; // arbitrary/unreachable
  index_current = -1; // no actions yet performed
}

-(Action*)getUndoAction {
  if(index_current < 0) { return NULL; }
  Action* undo_action = [actions objectAtIndex:index_current];
  --index_current;
  return undo_action;
}

-(Action*)getRedoAction {
  if(index_current > ([self signedSize] - 1)) { return NULL; }
  ++index_current;
  return [actions objectAtIndex:index_current];
}

-(void)pushAction:(Action*)action {
  int32_t current_size = [self signedSize];
  if(index_current <= (current_size - 2)) {
    // we re-did some thing(s), and now performed a new action at that location,
    // dismiss all further actions (redos) that used to come after this position
    int32_t count_to_remove = current_size - (index_current + 1);
    [(OFMutableArray<Action*>*)actions removeObjectsInRange:OFRangeMake(index_current+1, count_to_remove)];
  }
  if(current_size == depth_maximum) {
    // if we're at maximum depth, remove the first element,
    // and adjust the save point accordingly
    // (save point may now be unreachable)
    [(OFMutableArray<Action*>*)actions removeObjectAtIndex:0];
    --index_saved;
  }
  [(OFMutableArray<Action*>*)actions addObject:action];
  ++index_current;
}
@end
