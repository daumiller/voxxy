#ifndef VXX_MODEL_EDITOR_HEADER
#define VXX_MODEL_EDITOR_HEADER

#include "vxx-model.hpp"
#include <raylib.h>

class VxxModelFrameEditor : public VxxModelFrame {
public:
  bool addVoxel(VxxVoxel voxel_new);
  bool updateVoxel(int32_t x, int32_t y, int32_t z, VxxVoxel voxel_updated);
  bool removeVoxel(int32_t x, int32_t y, int32_t z);

  bool getVoxelColor(int32_t x, int32_t y, int32_t z, uint32_t* color);
  bool setVoxelColor(int32_t x, int32_t y, int32_t z, uint32_t color);
  bool moveVoxel(int32_t current_x, int32_t current_y, int32_t current_z, int32_t moved_x, int32_t moved_y, int32_t moved_z);
};

class VxxModelEditor : public VxxModel {
public:
  bool addFrame(const char* name, VxxModelFrame frame);
  bool removeFrame(const char* name);
  bool renameFrame(const char* old_name, const char* new_name);
};

#endif // ifndef VXX_MODEL_EDITOR_HEADER
