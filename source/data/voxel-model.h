#include <stdint.h>
#include <stdbool.h>
#import <ObjFW/ObjFW.h>

#define VOXEL_FACE_TOP     1  /* +y */
#define VOXEL_FACE_BOTTOM  2  /* -y */
#define VOXEL_FACE_LEFT    4  /* -x */
#define VOXEL_FACE_RIGHT   8  /* +x */
#define VOXEL_FACE_FRONT  16  /* +z */
#define VOXEL_FACE_BACK   32  /* -z */

@interface Voxel : OFObject {
@public
  int32_t x;
  int32_t y;
  int32_t z;
  uint32_t color;
  uint32_t reserved_1;
  uint32_t reserved_2;
  uint32_t reserved_3;
  uint32_t reserved_4;
}
-(id)initWithVoxel:(Voxel*)voxel;
@end

@interface VisibleVoxel : OFObject {
@public
  Voxel*  voxel;
  uint8_t faces;
}
@end

typedef struct {
  int32_t x;
  int32_t y;
  int32_t z;
} Vector3i;

@interface VoxelModelFrame : OFObject {
@public
  OFMutableDictionary<OFString*, Voxel*>* voxels;
}
-(OFArray<VisibleVoxel*>*)getVisibleVoxels;
-(bool)hasVoxelX:(int32_t)x Y:(int32_t)y Z:(int32_t)z;
-(bool)hasVoxel:(Vector3i)vector;
-(Voxel*)getVoxelX:(int32_t)x Y:(int32_t)y Z:(int32_t)z;
-(Voxel*)getVoxel:(Vector3i)vector;
@end

@interface VoxelModel : OFObject {
@public
  OFMutableDictionary<OFString*, VoxelModelFrame*>* frames;
}
-(id)init;
// -(id)initFromFile:(const char*)file_path;
-(VoxelModelFrame*)getFrameWithName:(const char*)name;
@end
