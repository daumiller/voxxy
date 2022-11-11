#include "vxx-model-editor.hpp"

bool VxxModelFrameEditor::addVoxel(VxxVoxel voxel_new) {
  char buffer[48];
  snprintf(buffer, 48, "%d_%d_%d", voxel_new.x, voxel_new.y, voxel_new.z);
  if(voxels.find(buffer) != voxels.end()) { return false; }
  voxels[buffer] = voxel_new;
  return true;
}

bool VxxModelFrameEditor::updateVoxel(int32_t x, int32_t y, int32_t z, VxxVoxel voxel_updated) {
  char buffer_current[48];
  snprintf(buffer_current, 48, "%d_%d_%d", x, y, z);
  if(voxels.find(buffer_current) == voxels.end()) { return false; }

  if((x == voxel_updated.x) && (y == voxel_updated.y) && (z == voxel_updated.z)) {
    voxels[buffer_current] = voxel_updated;
    return true;
  }

  char buffer_updated[48];
  snprintf(buffer_updated, 48, "%d_%d_%d", voxel_updated.x, voxel_updated.y, voxel_updated.z);
  if(voxels.find(buffer_updated) != voxels.end()) { return false; }
  voxels.erase(buffer_current);
  voxels[buffer_updated] = voxel_updated;
  return true;
}

bool VxxModelFrameEditor::removeVoxel(int32_t x, int32_t y, int32_t z) {
  char buffer[48];
  snprintf(buffer, 48, "%d_%d_%d", x, y, z);
  if(voxels.find(buffer) == voxels.end()) { return false; }
  voxels.erase(buffer);
  return true;
}

bool VxxModelFrameEditor::getVoxelColor(int32_t x, int32_t y, int32_t z, uint32_t* color) {
  char buffer[48];
  snprintf(buffer, 48, "%d_%d_%d", x, y, z);
  if(voxels.find(buffer) == voxels.end()) { return false; }
  if(color) { *color = voxels[buffer].color; }
  return true;
}

bool VxxModelFrameEditor::setVoxelColor(int32_t x, int32_t y, int32_t z, uint32_t color) {
  char buffer[48];
  snprintf(buffer, 48, "%d_%d_%d", x, y, z);
  if(voxels.find(buffer) == voxels.end()) { return false; }
  voxels[buffer].color = color;
  return true;
}

bool VxxModelFrameEditor::moveVoxel(int32_t current_x, int32_t current_y, int32_t current_z, int32_t moved_x, int32_t moved_y, int32_t moved_z) {
  char current_buffer[48];
  snprintf(current_buffer, 48, "%d_%d_%d", current_x, current_y, current_z);
  if(voxels.find(current_buffer) == voxels.end()) { return false; }

  char moved_buffer[48];
  snprintf(moved_buffer, 48, "%d_%d_%d", moved_x, moved_y, moved_z);
  if(voxels.find(moved_buffer) != voxels.end()) { return false; }

  VxxVoxel moved_voxel = voxels[current_buffer];
  moved_voxel.x = moved_x;
  moved_voxel.y = moved_y;
  moved_voxel.z = moved_z;
  voxels[moved_buffer] = moved_voxel;
  voxels.erase(current_buffer);
  return true;
}

bool VxxModelEditor::addFrame(const char* name, VxxModelFrame frame) {
  std::map<std::string, VxxModelFrame>::iterator position = frames.find(name);
  if(position != frames.end()) { return false; }
  frames[name] = frame;
  return true;
}

bool VxxModelEditor::removeFrame(const char* name) {
  std::map<std::string, VxxModelFrame>::iterator position = frames.find(name);
  if(position == frames.end()) { return false; }
  frames.erase(name);
  return true;
}

bool VxxModelEditor::renameFrame(const char* old_name, const char* new_name) {
  std::map<std::string, VxxModelFrame>::iterator position = frames.find(old_name);
  if(position == frames.end()) { return false; }
  position = frames.find(new_name);
  if(position != frames.end()) { return false; }

  frames[new_name] = frames[old_name];
  frames.erase(old_name);
  return true;
}
