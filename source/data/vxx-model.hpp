#ifndef VXX_MODEL_HEADER
#define VXX_MODEL_HEADER

#include <map>
#include <string>
#include <vector>
#include <unordered_map>
#include <stdint.h>
#include <stdbool.h>

#define VXX_VOXEL_FACE_TOP     1  /* +y */
#define VXX_VOXEL_FACE_BOTTOM  2  /* -y */
#define VXX_VOXEL_FACE_LEFT    4  /* -x */
#define VXX_VOXEL_FACE_RIGHT   8  /* +x */
#define VXX_VOXEL_FACE_FRONT  16  /* +z */
#define VXX_VOXEL_FACE_BACK   32  /* -z */

typedef struct {
  int32_t x;
  int32_t y;
  int32_t z;
  uint32_t color;
  uint32_t reserved_1;
  uint32_t reserved_2;
  uint32_t reserved_3;
  uint32_t reserved_4;
} VxxVoxel;

typedef struct {
  VxxVoxel voxel;
  uint8_t  faces;
} VxxVisibleVoxel;

class VxxModelFrame {
public:
  std::vector<VxxVisibleVoxel>* getVisibleVoxels();
  bool hasVoxel(int32_t x, int32_t y, int32_t z);
  VxxVoxel* getVoxel(int32_t x, int32_t y, int32_t z);
  std::unordered_map<std::string, VxxVoxel> voxels;
};

class VxxModel {
public:
  VxxModelFrame* getFrame(const char* name);
  std::map<std::string, VxxModelFrame> frames;
};

#endif // ifndef VXX_MODEL_HEADER
