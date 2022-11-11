#ifndef EDITOR_FACE_MODELS_HEADER
#define EDITOR_FACE_MODELS_HEADER

#include <raylib.h>
#include "../data/vxx-model.hpp"

typedef struct {
  Model top;
  Model bottom;
  Model left;
  Model right;
  Model front;
  Model back;
} VoxelFaceModels;

void generateVoxelFaceModels(VoxelFaceModels* models);

#endif // ifndef EDITOR_FACE_MODELS_HEADER
