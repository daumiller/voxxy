#include "vxx-model.hpp"
#include <string.h>

std::vector<VxxVisibleVoxel>* VxxModelFrame::getVisibleVoxels() {
  std::vector<VxxVisibleVoxel>* visible_voxels = new std::vector<VxxVisibleVoxel>();

  std::unordered_map<std::string, VxxVoxel>::iterator iterator = voxels.begin();
  while(iterator != voxels.end()) {
    VxxVoxel vox = iterator->second;
    uint8_t faces = 0;
    if(hasVoxel(vox.x,   vox.y+1, vox.z  ) == false) { faces |= VXX_VOXEL_FACE_TOP;    }
    if(hasVoxel(vox.x,   vox.y-1, vox.z  ) == false) { faces |= VXX_VOXEL_FACE_BOTTOM; }
    if(hasVoxel(vox.x-1, vox.y,   vox.z  ) == false) { faces |= VXX_VOXEL_FACE_LEFT;   }
    if(hasVoxel(vox.x+1, vox.y,   vox.z  ) == false) { faces |= VXX_VOXEL_FACE_RIGHT;  }
    if(hasVoxel(vox.x,   vox.y,   vox.z+1) == false) { faces |= VXX_VOXEL_FACE_FRONT;  }
    if(hasVoxel(vox.x,   vox.y,   vox.z-1) == false) { faces |= VXX_VOXEL_FACE_BACK;   }
    if(faces) {
      visible_voxels->push_back({ .voxel = vox, .faces = faces });
    }

    iterator++;
  }

  return visible_voxels;
}

bool VxxModelFrame::hasVoxel(int32_t x, int32_t y, int32_t z) {
  char buffer[48];
  snprintf(buffer, 48, "%d_%d_%d", x, y, z);
  return (voxels.find(buffer) != voxels.end());
}

VxxVoxel* VxxModelFrame::getVoxel(int32_t x, int32_t y, int32_t z) {
  char buffer[48];
  snprintf(buffer, 48, "%d_%d_%d", x, y, z);
  std::unordered_map<std::string, VxxVoxel>::iterator position = voxels.find(buffer);
  if(position == voxels.end()) { return NULL; }
  return &(position->second);
}

VxxModelFrame* VxxModel::getFrame(const char* name) {
  std::map<std::string, VxxModelFrame>::iterator position = frames.find(name);
  if(position == frames.end()) { return NULL; }
  return &(position->second);
}
