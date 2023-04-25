#import "voxel-model.h"

@interface VoxFile : OFObject
+(OFArray<Voxel*>*)readVoxels:(OFString*)path;
@end
