#import <ObjFW/ObjFW.h>
#include <raylib.h>

@interface VoxelFaceModels : OFObject {
  Model top;
  Model bottom;
  Model left;
  Model right;
  Model front;
  Model back;
}
-(Model*)modelForFace:(int32_t)face;
@end
