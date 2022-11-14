#import "voxel-model.h"

@interface VoxelModelFrameEditor : VoxelModelFrame
// addVoxel, uppdateVoxel, removeVoxel
-(bool)addVoxel:(Voxel*)voxel;
-(bool)addVoxelX:(int32_t)x Y:(int32_t)y Z:(int32_t)z Color:(uint32_t)color;
-(bool)addVoxelXYZ:(Vector3i)vector Color:(uint32_t)color;
-(bool)updateVoxel:(Voxel*)voxel_original withVoxel:(Voxel*)voxel_updated;
-(bool)updateVoxelX:(int32_t)x Y:(int32_t)y Z:(int32_t)z withVoxel:(Voxel*)voxel_updated;
-(bool)updateVoxelXYZ:(Vector3i)vector withVoxel:(Voxel*)voxel_updated;
-(bool)removeVoxel:(Voxel*)voxel;
-(bool)removeVoxelX:(int32_t)x Y:(int32_t)y Z:(int32_t)z;
-(bool)removeVoxelXYZ:(Vector3i)vector;
// lookupVoxel
-(Voxel*)lookupVoxelX:(int32_t)x Y:(int32_t)y Z:(int32_t)z;

// getVoxelColor, setVoxelColor
-(bool)getVoxel:(Voxel*)voxel Color:(uint32_t*)color;
-(bool)getVoxelX:(int32_t)x Y:(int32_t)y Z:(int32_t)z Color:(uint32_t*)color;
-(bool)getVoxelXYZ:(Vector3i)vector Color:(uint32_t*)color;
-(bool)setVoxel:(Voxel*)voxel Color:(uint32_t)color;
-(bool)setVoxelX:(int32_t)x Y:(int32_t)y Z:(int32_t)z Color:(uint32_t)color;
-(bool)setVoxelXYZ:(Vector3i)vector Color:(uint32_t)color;

// moveVoxel
-(bool)moveVoxel:(Voxel*)voxel toX:(int32_t)x Y:(int32_t)y Z:(int32_t)z;
-(bool)moveVoxelX:(int32_t)current_x Y:(int32_t)current_y Z:(int32_t)current_z toX:(int32_t)moved_x Y:(int32_t)moved_y Z:(int32_t)moved_z;
-(bool)moveVoxelXYZ:(Vector3i)vector_from toXYZ:(Vector3i)vector_to;
@end

@interface VoxelModelEditor : VoxelModel
-(bool)addFrame:(VoxelModelFrame*)frame withName:(const char*)name;
-(bool)removeFrame:(const char*)name;
-(bool)renameFrame:(const char*)name_old to:(const char*)name_new;
@end
