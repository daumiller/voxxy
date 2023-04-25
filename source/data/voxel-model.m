#import "voxel-model.h"
#import "voxel-model-editor.h"
#import "voxfile.h"

#define LOOKUP_FORMAT_STRING "%d_%d_%d"

// Voxel ==========================================================================================================================
@implementation Voxel
-(id)initWithVoxel:(Voxel*)voxel {
  self = [super init];
  if(!self) { return self; }

  x          = voxel->x;
  y          = voxel->y;
  z          = voxel->z;
  color      = voxel->color;
  reserved_1 = voxel->reserved_1;
  reserved_2 = voxel->reserved_1;
  reserved_3 = voxel->reserved_1;
  reserved_4 = voxel->reserved_1;
  return self;
}
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

-(OFArray<VisibleVoxel*>*)getVisibleVoxelsWithBounds:(Bounds3Di*)bounds {
  OFMutableArray<VisibleVoxel*>* visible_voxels = [[OFMutableArray alloc] init];
  bounds->minimum.x = INT_MAX;  bounds->maximum.x = INT_MIN;
  bounds->minimum.y = INT_MAX;  bounds->maximum.y = INT_MIN;
  bounds->minimum.z = INT_MAX;  bounds->maximum.z = INT_MIN;

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
      if(voxel->x < bounds->minimum.x) { bounds->minimum.x = voxel->x; }  if(voxel->x > bounds->maximum.x) { bounds->maximum.x = voxel->x; }
      if(voxel->y < bounds->minimum.y) { bounds->minimum.y = voxel->y; }  if(voxel->y > bounds->maximum.y) { bounds->maximum.y = voxel->y; }
      if(voxel->z < bounds->minimum.z) { bounds->minimum.z = voxel->z; }  if(voxel->z > bounds->maximum.z) { bounds->maximum.z = voxel->z; }
      VisibleVoxel* visible = [[VisibleVoxel alloc] init];
      visible->faces = faces;
      visible->voxel = voxel;
      [visible_voxels addObject:visible];
      [visible release];
    }
  }

  return visible_voxels;
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

-(id)initFromFile:(OFString*)file_path {
  self = [super init];
  if(!self) { return self; }

  OFArray<Voxel*>* voxels = [VoxFile readVoxels:file_path];
  if(!voxels) { [self release]; return nil; }

  VoxelModelFrameEditor* default_frame = [[VoxelModelFrameEditor alloc] init];
  for(Voxel* voxel in voxels) {
    [default_frame addVoxelX:voxel->x Y:voxel->y Z:voxel->z Color:voxel->color];
  }
  [voxels release];
  frames = [[OFMutableDictionary alloc] init];
  [frames setObject:default_frame forKey:@"default"];
  [default_frame release];

  return self;
}

-(void)dealloc {
  if(frames) { [frames release]; }
  [super dealloc];
}

-(VoxelModelFrame*)getFrameWithName:(const char*)name {
  OFString *name_string = [[OFString alloc] initWithCString:name encoding:OFStringEncodingUTF8];
  VoxelModelFrame* result = [frames objectForKey:name_string];
  [name_string release];
  return result;
}
@end
