#import "voxfile.h"

@implementation VoxFile
+(OFArray<Voxel*>*)readVoxels:(OFString*)path {
  void* pool = objc_autoreleasePoolPush();
  const char* file_path = [path UTF8String];

  FILE* file = fopen(file_path, "rb");
  if(file == NULL) { objc_autoreleasePoolPop(pool); return nil; }

  uint8_t four_bytes[4];
  // check signature (4b), skip version (4b)
  fread(four_bytes, 1, 4, file);
  if((four_bytes[0] != 'V') || (four_bytes[1] != 'O') || (four_bytes[2] != 'X') || (four_bytes[3] != 0x20)) { objc_autoreleasePoolPop(pool); return nil; }
  fread(four_bytes, 1, 4, file);
  // read MAIN chunk, skip size & child size
  fread(four_bytes, 1, 4, file);
  if((four_bytes[0] != 'M') || (four_bytes[1] != 'A') || (four_bytes[2] != 'I') || (four_bytes[3] != 'N')) { objc_autoreleasePoolPop(pool); return nil; }
  fread(four_bytes, 1, 4, file);
  fread(four_bytes, 1, 4, file);

  uint32_t palette[256];
  OFMutableArray<Voxel*>* voxels = [[OFMutableArray alloc] init];
  bool read_palette = false;
  bool read_voxels  = false;

  // read chunks until parsed first XYZI and RGBA chunks
  while(!read_palette && !read_voxels && !feof(file)) {
    fread(four_bytes, 4, 1, file);
    if((four_bytes[0] == 'X') && (four_bytes[1] == 'Y') && (four_bytes[2] == 'Z') && (four_bytes[3] == 'I')) {
      fread(four_bytes, 1, 4, file);
      fread(four_bytes, 1, 4, file);
      uint32_t voxel_count = 0;
      fread(&voxel_count, 4, 1, file);
      for(uint32_t idx=0; idx<voxel_count; ++idx) {
        fread(four_bytes, 4, 1, file);
        Voxel* voxel = [[Voxel alloc] init];
        voxel->x = four_bytes[0];
        voxel->z = four_bytes[1];
        voxel->y = four_bytes[2];
        voxel->reserved_1 = four_bytes[3];
        [voxels addObject:voxel];
        [voxel release];
      }
      read_voxels = true;
      fread(four_bytes, 4, 1, file);
    }
    if((four_bytes[0] == 'R') && (four_bytes[1] == 'G') && (four_bytes[2] == 'B') && (four_bytes[3] == 'A')) {
      for(uint32_t idx=0; idx<256; ++idx) {
        fread(four_bytes, 4, 1, file);
        palette[idx] = ((uint32_t)four_bytes[0]) << 24 | ((uint32_t)four_bytes[1]) << 16 | ((uint32_t)four_bytes[2]) << 8 | ((uint32_t)four_bytes[3]);
        // fread(&palette[idx], 4, 1, file);
      }
      read_palette = true;
      fread(four_bytes, 4, 1, file);
    }

    uint32_t skip_size;
    fread(&skip_size, 4, 1, file);
    fread(four_bytes, 4, 1, file);
    fseek(file, skip_size, SEEK_CUR);
  }

  if(!read_palette || !read_voxels) {
    [voxels release];
    objc_autoreleasePoolPop(pool);
    return nil;
  }

  for(Voxel* voxel in voxels) {
    voxel->color = palette[voxel->reserved_1];
  }

  objc_autoreleasePoolPop(pool);
  return voxels;
}
@end
