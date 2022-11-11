#include "editor-face-models.hpp"

static Mesh generateVoxelFaceMesh(uint8_t face_type) {
  Mesh face_mesh = { 0 };
  face_mesh.vertexCount   = 4;
  face_mesh.triangleCount = 2;
  face_mesh.vertices = (float*)RL_MALLOC(12 * sizeof(float));
  face_mesh.indices  = (uint16_t*)RL_MALLOC(6 * sizeof(uint16_t));
  face_mesh.indices[0] = 0;
  face_mesh.indices[1] = 1;
  face_mesh.indices[2] = 2;
  face_mesh.indices[3] = 1;
  face_mesh.indices[4] = 3;
  face_mesh.indices[5] = 2;

  switch(face_type) {
    case VXX_VOXEL_FACE_FRONT:
      face_mesh.vertices[ 0]=-0.5f; face_mesh.vertices[ 1]=-0.5f; face_mesh.vertices[ 2]=+0.5f;
      face_mesh.vertices[ 3]=+0.5f; face_mesh.vertices[ 4]=-0.5f; face_mesh.vertices[ 5]=+0.5f;
      face_mesh.vertices[ 6]=-0.5f; face_mesh.vertices[ 7]=+0.5f; face_mesh.vertices[ 8]=+0.5f;
      face_mesh.vertices[ 9]=+0.5f; face_mesh.vertices[10]=+0.5f; face_mesh.vertices[11]=+0.5f;
    break;

    case VXX_VOXEL_FACE_BACK:
      face_mesh.vertices[ 0]=+0.5f; face_mesh.vertices[ 1]=-0.5f; face_mesh.vertices[ 2]=-0.5f;
      face_mesh.vertices[ 3]=-0.5f; face_mesh.vertices[ 4]=-0.5f; face_mesh.vertices[ 5]=-0.5f;
      face_mesh.vertices[ 6]=+0.5f; face_mesh.vertices[ 7]=+0.5f; face_mesh.vertices[ 8]=-0.5f;
      face_mesh.vertices[ 9]=-0.5f; face_mesh.vertices[10]=+0.5f; face_mesh.vertices[11]=-0.5f;
    break;

    case VXX_VOXEL_FACE_LEFT:
      face_mesh.vertices[ 0]=-0.5f; face_mesh.vertices[ 1]=-0.5f; face_mesh.vertices[ 2]=-0.5f;
      face_mesh.vertices[ 3]=-0.5f; face_mesh.vertices[ 4]=-0.5f; face_mesh.vertices[ 5]=+0.5f;
      face_mesh.vertices[ 6]=-0.5f; face_mesh.vertices[ 7]=+0.5f; face_mesh.vertices[ 8]=-0.5f;
      face_mesh.vertices[ 9]=-0.5f; face_mesh.vertices[10]=+0.5f; face_mesh.vertices[11]=+0.5f;
    break;

    case VXX_VOXEL_FACE_RIGHT:
      face_mesh.vertices[ 0]=+0.5f; face_mesh.vertices[ 1]=-0.5f; face_mesh.vertices[ 2]=+0.5f;
      face_mesh.vertices[ 3]=+0.5f; face_mesh.vertices[ 4]=-0.5f; face_mesh.vertices[ 5]=-0.5f;
      face_mesh.vertices[ 6]=+0.5f; face_mesh.vertices[ 7]=+0.5f; face_mesh.vertices[ 8]=+0.5f;
      face_mesh.vertices[ 9]=+0.5f; face_mesh.vertices[10]=+0.5f; face_mesh.vertices[11]=-0.5f;
    break;

    case VXX_VOXEL_FACE_TOP:
      face_mesh.vertices[ 0]=-0.5f; face_mesh.vertices[ 1]=+0.5f; face_mesh.vertices[ 2]=+0.5f;
      face_mesh.vertices[ 3]=+0.5f; face_mesh.vertices[ 4]=+0.5f; face_mesh.vertices[ 5]=+0.5f;
      face_mesh.vertices[ 6]=-0.5f; face_mesh.vertices[ 7]=+0.5f; face_mesh.vertices[ 8]=-0.5f;
      face_mesh.vertices[ 9]=+0.5f; face_mesh.vertices[10]=+0.5f; face_mesh.vertices[11]=-0.5f;
    break;

    case VXX_VOXEL_FACE_BOTTOM:
      face_mesh.vertices[ 0]=+0.5f; face_mesh.vertices[ 1]=-0.5f; face_mesh.vertices[ 2]=+0.5f;
      face_mesh.vertices[ 3]=-0.5f; face_mesh.vertices[ 4]=-0.5f; face_mesh.vertices[ 5]=+0.5f;
      face_mesh.vertices[ 6]=+0.5f; face_mesh.vertices[ 7]=-0.5f; face_mesh.vertices[ 8]=-0.5f;
      face_mesh.vertices[ 9]=-0.5f; face_mesh.vertices[10]=-0.5f; face_mesh.vertices[11]=-0.5f;
    break;
  }

  return face_mesh;
}

void generateVoxelFaceModels(VoxelFaceModels* models) {
  Mesh mesh_top    = generateVoxelFaceMesh(VXX_VOXEL_FACE_TOP   ); UploadMesh(&mesh_top   , false); models->top    = LoadModelFromMesh(mesh_top   );
  Mesh mesh_bottom = generateVoxelFaceMesh(VXX_VOXEL_FACE_BOTTOM); UploadMesh(&mesh_bottom, false); models->bottom = LoadModelFromMesh(mesh_bottom);
  Mesh mesh_left   = generateVoxelFaceMesh(VXX_VOXEL_FACE_LEFT  ); UploadMesh(&mesh_left  , false); models->left   = LoadModelFromMesh(mesh_left  );
  Mesh mesh_right  = generateVoxelFaceMesh(VXX_VOXEL_FACE_RIGHT ); UploadMesh(&mesh_right , false); models->right  = LoadModelFromMesh(mesh_right );
  Mesh mesh_front  = generateVoxelFaceMesh(VXX_VOXEL_FACE_FRONT ); UploadMesh(&mesh_front , false); models->front  = LoadModelFromMesh(mesh_front );
  Mesh mesh_back   = generateVoxelFaceMesh(VXX_VOXEL_FACE_BACK  ); UploadMesh(&mesh_back  , false); models->back   = LoadModelFromMesh(mesh_back  );
}
