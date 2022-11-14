#import "voxel-model-editor.h"

#define LOOKUP_FORMAT_STRING "%d_%d_%d"

// VoxelModelFrameEditor ==========================================================================================================
@implementation VoxelModelFrameEditor
// - - - - addVoxel - - - -
-(bool)addVoxel:(Voxel*)voxel {
  OFString* lookup = [[OFString alloc] initWithFormat:@LOOKUP_FORMAT_STRING, voxel->x, voxel->y, voxel->z];
  if([voxels objectForKey:lookup] != nil) { [lookup release]; return false; }
  [voxels setObject:voxel forKey:lookup];
  [lookup release];
  return true;
}
-(bool)addVoxelX:(int32_t)x Y:(int32_t)y Z:(int32_t)z Color:(uint32_t)color {
  Voxel* voxel = [[Voxel alloc] init];
  voxel->x = x;
  voxel->y = y;
  voxel->z = z;
  voxel->color = color;
  bool result = [self addVoxel:voxel];
  [voxel release];
  return result;
}
-(bool)addVoxelXYZ:(Vector3i)vector Color:(uint32_t)color {
  Voxel* voxel = [[Voxel alloc] init];
  voxel->x = vector.x;
  voxel->y = vector.y;
  voxel->z = vector.z;
  voxel->color = color;
  bool result = [self addVoxel:voxel];
  [voxel release];
  return result;
}

// - - - - updateVoxel - - - -
-(bool)updateVoxel:(Voxel*)voxel_original withVoxel:(Voxel*)voxel_updated {
  return [self updateVoxelX:voxel_original->x Y:voxel_original->y Z:voxel_original->z withVoxel:voxel_updated];
}
-(bool)updateVoxelX:(int32_t)x Y:(int32_t)y Z:(int32_t)z withVoxel:(Voxel*)voxel_updated {
  OFString* lookup = [[OFString alloc] initWithFormat:@LOOKUP_FORMAT_STRING, x, y, z];
  Voxel* voxel = [voxels objectForKey:lookup];
  if(voxel == nil) { [lookup release]; return false; }

  if((voxel->x != voxel_updated->x) || (voxel->y != voxel_updated->y) || (voxel->z != voxel_updated->z)) {
    OFString* lookup_updated = [[OFString alloc] initWithFormat:@LOOKUP_FORMAT_STRING, voxel_updated->x, voxel_updated->y, voxel_updated->z];
    if([voxels objectForKey:lookup_updated] != NULL) {
      [lookup_updated release];
      [lookup release];
      return false;
    }

    [voxel retain];
    [voxels removeObjectForKey:lookup];
    [voxels setObject:voxel forKey:lookup_updated];
    [lookup_updated release];
  }
  [lookup release];

  voxel->x          = voxel_updated->x         ;
  voxel->y          = voxel_updated->y         ;
  voxel->z          = voxel_updated->z         ;
  voxel->color      = voxel_updated->color     ;
  voxel->reserved_1 = voxel_updated->reserved_1;
  voxel->reserved_2 = voxel_updated->reserved_2;
  voxel->reserved_3 = voxel_updated->reserved_3;
  voxel->reserved_4 = voxel_updated->reserved_4;
  return true;
}
-(bool)updateVoxelXYZ:(Vector3i)vector withVoxel:(Voxel*)voxel_updated {
  return [self updateVoxelX:vector.x Y:vector.y Z:vector.z withVoxel:voxel_updated];
}

// - - - - removeVoxel - - - -
-(bool)removeVoxel:(Voxel*)voxel {
  return [self removeVoxelX:voxel->x Y:voxel->y Z:voxel->z];
}
-(bool)removeVoxelX:(int32_t)x Y:(int32_t)y Z:(int32_t)z {
  OFString* lookup = [[OFString alloc] initWithFormat:@LOOKUP_FORMAT_STRING, x, y, z];
  Voxel* voxel = [voxels objectForKey:lookup];
  if(voxel == nil) { [lookup release]; return false; }

  [voxels removeObjectForKey:lookup];
  [lookup release];
  return true;
}
-(bool)removeVoxelXYZ:(Vector3i)vector {
  return [self removeVoxelX:vector.x Y:vector.y Z:vector.z];
}

// - - - - lookupVoxelX - - - -
-(Voxel*)lookupVoxelX:(int32_t)x Y:(int32_t)y Z:(int32_t)z {
  OFString* lookup = [[OFString alloc] initWithFormat:@LOOKUP_FORMAT_STRING, x, y, z];
  Voxel* voxel = [voxels objectForKey:lookup];
  [lookup release];
  return voxel;
}

// - - - - getVoxelColor - - - -
-(bool)getVoxel:(Voxel*)voxel Color:(uint32_t*)color {
  return [self getVoxelX:voxel->x Y:voxel->y Z:voxel->z Color:color];
}
-(bool)getVoxelX:(int32_t)x Y:(int32_t)y Z:(int32_t)z Color:(uint32_t*)color {
  OFString* lookup = [[OFString alloc] initWithFormat:@LOOKUP_FORMAT_STRING, x, y, z];
  Voxel* voxel = [voxels objectForKey:lookup];
  [lookup release];
  if(voxel == nil) { return false; }
  if(color) { *color = voxel->color; }
  return true;
}
-(bool)getVoxelXYZ:(Vector3i)vector Color:(uint32_t*)color {
  return [self getVoxelX:vector.x Y:vector.y Z:vector.z Color:color];
}

// - - - - setVoxelColor - - - -
-(bool)setVoxel:(Voxel*)voxel Color:(uint32_t)color {
  return [self setVoxelX:voxel->x Y:voxel->y Z:voxel->z Color:color];
}
-(bool)setVoxelX:(int32_t)x Y:(int32_t)y Z:(int32_t)z Color:(uint32_t)color {
  OFString* lookup = [[OFString alloc] initWithFormat:@LOOKUP_FORMAT_STRING, x, y, z];
  Voxel* voxel = [voxels objectForKey:lookup];
  [lookup release];
  if(voxel == nil) { return false; }
  voxel->color = color;
  return true;
}
-(bool)setVoxelXYZ:(Vector3i)vector Color:(uint32_t)color {
  return [self setVoxelX:vector.x Y:vector.y Z:vector.z Color:color];
}

// - - - - moveVoxel - - - -
-(bool)moveVoxel:(Voxel*)voxel toX:(int32_t)x Y:(int32_t)y Z:(int32_t)z {
  return [self moveVoxelX:voxel->x Y:voxel->y Z:voxel->z toX:x Y:y Z:z];
}
-(bool)moveVoxelX:(int32_t)current_x Y:(int32_t)current_y Z:(int32_t)current_z toX:(int32_t)moved_x Y:(int32_t)moved_y Z:(int32_t)moved_z {
  OFString* lookup_current = [[OFString alloc] initWithFormat:@LOOKUP_FORMAT_STRING, current_x, current_y, current_z];
  OFString* lookup_moved   = [[OFString alloc] initWithFormat:@LOOKUP_FORMAT_STRING, moved_x,   moved_y,   moved_z  ];

  Voxel* voxel_current = [voxels objectForKey:lookup_current];
  Voxel* voxel_moved   = [voxels objectForKey:lookup_moved  ];
  if((voxel_current == NULL) || (voxel_moved != NULL)) {
    [lookup_current release];
    [lookup_moved   release];
    return false;
  }

  [voxel_current retain];
  [voxels removeObjectForKey:lookup_current];
  [voxels setObject:voxel_current forKey:lookup_moved];
  [voxel_current release];

  [lookup_current release];
  [lookup_moved   release];

  voxel_current->x = moved_x;
  voxel_current->y = moved_y;
  voxel_current->z = moved_z;
  return true;
}
-(bool)moveVoxelXYZ:(Vector3i)vector_from toXYZ:(Vector3i)vector_to {
  return [self moveVoxelX:vector_from.x Y:vector_from.y Z:vector_from.z toX:vector_to.x Y:vector_to.y Z:vector_to.z];
}
@end

// VoxelModelEditor ===============================================================================================================
@implementation VoxelModelEditor
-(bool)addFrame:(VoxelModelFrame*)frame withName:(const char*)name {
  OFString* name_string = [[OFString alloc] initWithCString:name encoding:OFStringEncodingUTF8];
  VoxelModelFrame* existing_frame = frames[name_string];
  if(existing_frame) {
    [name_string release];
    return false;
  }

  [frames setObject:frame forKey:name_string];
  [name_string release];
  return true;
}

-(bool)removeFrame:(const char*)name {
  OFString* name_string = [[OFString alloc] initWithCString:name encoding:OFStringEncodingUTF8];
  VoxelModelFrame* existing_frame = frames[name_string];
  if(existing_frame == NULL) {
    [name_string release];
    return false;
  }

  [frames removeObjectForKey:name_string];
  [name_string release];
  return true;
}

-(bool)renameFrame:(const char*)name_old to:(const char*)name_new {
  OFString* name_old_string = [[OFString alloc] initWithCString:name_old encoding:OFStringEncodingUTF8];
  OFString* name_new_string = [[OFString alloc] initWithCString:name_new encoding:OFStringEncodingUTF8];
  VoxelModelFrame* existing_frame_old = frames[name_old_string];
  VoxelModelFrame* existing_frame_new = frames[name_new_string];
  if((existing_frame_old == NULL) || (existing_frame_new != NULL)) {
    [name_old_string release];
    [name_new_string release];
    return false;
  }

  [existing_frame_old retain];
  [frames removeObjectForKey:name_old_string];
  [frames setObject:existing_frame_old forKey:name_new_string];
  [existing_frame_old release];

  [name_old_string release];
  [name_new_string release];
  return true;
}
@end
