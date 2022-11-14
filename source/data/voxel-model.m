#import "voxel-model.h"

#define LOOKUP_FORMAT_STRING "%d_%d_%d"

// Voxel ==========================================================================================================================
@implementation Voxel
@end

// VisibleVoxel ===================================================================================================================
@implementation VisibleVoxel
@end

// VoxelFrame =====================================================================================================================
@implementation VoxelModelFrame
-(id)init {
  self = [super init];
  if(!self) { return self; }

  voxels = [[OFMutableDictionary alloc] init];
  return self;
}

-(void)dealloc {
  [voxels release];
  [super dealloc];
}

-(bool)hasVoxelX:(int32_t)x Y:(int32_t)y Z:(int32_t)z {
  OFString* lookup = [[OFString alloc] initWithFormat:@LOOKUP_FORMAT_STRING, x, y, z];
  bool result = ([voxels objectForKey:lookup] != nil);
  [lookup release];
  return result;
}

-(bool)hasVoxel:(Vector3i)vector {
  OFString* lookup = [[OFString alloc] initWithFormat:@LOOKUP_FORMAT_STRING, vector.x, vector.y, vector.z];
  bool result = ([voxels objectForKey:lookup] != nil);
  [lookup release];
  return result;
}

-(Voxel*)getVoxelX:(int32_t)x Y:(int32_t)y Z:(int32_t)z {
  OFString* lookup = [[OFString alloc] initWithFormat:@LOOKUP_FORMAT_STRING, x, y, z];
  Voxel* result = [voxels objectForKey:lookup];
  [lookup release];
  return result;
}

-(Voxel*)getVoxel:(Vector3i)vector {
  OFString* lookup = [[OFString alloc] initWithFormat:@LOOKUP_FORMAT_STRING, vector.x, vector.y, vector.z];
  Voxel* result = [voxels objectForKey:lookup];
  [lookup release];
  return result;
}

-(OFArray*)getVisibleVoxels {
  OFMutableArray<VisibleVoxel*>* visible_voxels = [[OFMutableArray alloc] init];

  for(OFString* key in voxels) {
    Voxel* voxel = voxels[key];
    uint8_t faces = 0;
    if([self hasVoxelX:voxel->x   Y:voxel->y+1 Z:voxel->z  ] == false) { faces |= VOXEL_FACE_TOP;    }
    if([self hasVoxelX:voxel->x   Y:voxel->y-1 Z:voxel->z  ] == false) { faces |= VOXEL_FACE_BOTTOM; }
    if([self hasVoxelX:voxel->x-1 Y:voxel->y   Z:voxel->z  ] == false) { faces |= VOXEL_FACE_LEFT;   }
    if([self hasVoxelX:voxel->x+1 Y:voxel->y   Z:voxel->z  ] == false) { faces |= VOXEL_FACE_RIGHT;  }
    if([self hasVoxelX:voxel->x   Y:voxel->y   Z:voxel->z+1] == false) { faces |= VOXEL_FACE_FRONT;  }
    if([self hasVoxelX:voxel->x   Y:voxel->y   Z:voxel->z-1] == false) { faces |= VOXEL_FACE_BACK;   }
    if(faces) {
      VisibleVoxel* visible = [[VisibleVoxel alloc] init];
      visible->faces = faces;
      visible->voxel = voxel;
      [visible_voxels addObject:visible];
      [visible release];
    }
  }

  return visible_voxels;
}
@end

// VoxelModel =====================================================================================================================
@implementation VoxelModel
-(id)init {
  self = [super init];
  if(!self) { return self; }

  frames = [[OFMutableDictionary alloc] init];
  return self;
}

-(void)dealloc {
  [frames release];
  [super dealloc];
}

-(VoxelModelFrame*)getFrameWithName:(const char*)name {
  OFString *name_string = [[OFString alloc] initWithCString:name encoding:OFStringEncodingUTF8];
  VoxelModelFrame* result = [frames objectForKey:name_string];
  [name_string release];
  return result;
}
@end
