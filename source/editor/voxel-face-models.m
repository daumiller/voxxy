#import "voxel-face-models.h"
#import "../data/voxel-model.h"

// Helpers ========================================================================================================================
static Mesh generateVoxelFaceMesh(int32_t face_type) {
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
    case VOXEL_FACE_FRONT:
      face_mesh.vertices[ 0]=-0.5f; face_mesh.vertices[ 1]=-0.5f; face_mesh.vertices[ 2]=+0.5f;
      face_mesh.vertices[ 3]=+0.5f; face_mesh.vertices[ 4]=-0.5f; face_mesh.vertices[ 5]=+0.5f;
      face_mesh.vertices[ 6]=-0.5f; face_mesh.vertices[ 7]=+0.5f; face_mesh.vertices[ 8]=+0.5f;
      face_mesh.vertices[ 9]=+0.5f; face_mesh.vertices[10]=+0.5f; face_mesh.vertices[11]=+0.5f;
    break;

    case VOXEL_FACE_BACK:
      face_mesh.vertices[ 0]=+0.5f; face_mesh.vertices[ 1]=-0.5f; face_mesh.vertices[ 2]=-0.5f;
      face_mesh.vertices[ 3]=-0.5f; face_mesh.vertices[ 4]=-0.5f; face_mesh.vertices[ 5]=-0.5f;
      face_mesh.vertices[ 6]=+0.5f; face_mesh.vertices[ 7]=+0.5f; face_mesh.vertices[ 8]=-0.5f;
      face_mesh.vertices[ 9]=-0.5f; face_mesh.vertices[10]=+0.5f; face_mesh.vertices[11]=-0.5f;
    break;

    case VOXEL_FACE_LEFT:
      face_mesh.vertices[ 0]=-0.5f; face_mesh.vertices[ 1]=-0.5f; face_mesh.vertices[ 2]=-0.5f;
      face_mesh.vertices[ 3]=-0.5f; face_mesh.vertices[ 4]=-0.5f; face_mesh.vertices[ 5]=+0.5f;
      face_mesh.vertices[ 6]=-0.5f; face_mesh.vertices[ 7]=+0.5f; face_mesh.vertices[ 8]=-0.5f;
      face_mesh.vertices[ 9]=-0.5f; face_mesh.vertices[10]=+0.5f; face_mesh.vertices[11]=+0.5f;
    break;

    case VOXEL_FACE_RIGHT:
      face_mesh.vertices[ 0]=+0.5f; face_mesh.vertices[ 1]=-0.5f; face_mesh.vertices[ 2]=+0.5f;
      face_mesh.vertices[ 3]=+0.5f; face_mesh.vertices[ 4]=-0.5f; face_mesh.vertices[ 5]=-0.5f;
      face_mesh.vertices[ 6]=+0.5f; face_mesh.vertices[ 7]=+0.5f; face_mesh.vertices[ 8]=+0.5f;
      face_mesh.vertices[ 9]=+0.5f; face_mesh.vertices[10]=+0.5f; face_mesh.vertices[11]=-0.5f;
    break;

    case VOXEL_FACE_TOP:
      face_mesh.vertices[ 0]=-0.5f; face_mesh.vertices[ 1]=+0.5f; face_mesh.vertices[ 2]=+0.5f;
      face_mesh.vertices[ 3]=+0.5f; face_mesh.vertices[ 4]=+0.5f; face_mesh.vertices[ 5]=+0.5f;
      face_mesh.vertices[ 6]=-0.5f; face_mesh.vertices[ 7]=+0.5f; face_mesh.vertices[ 8]=-0.5f;
      face_mesh.vertices[ 9]=+0.5f; face_mesh.vertices[10]=+0.5f; face_mesh.vertices[11]=-0.5f;
    break;

    case VOXEL_FACE_BOTTOM:
      face_mesh.vertices[ 0]=+0.5f; face_mesh.vertices[ 1]=-0.5f; face_mesh.vertices[ 2]=+0.5f;
      face_mesh.vertices[ 3]=-0.5f; face_mesh.vertices[ 4]=-0.5f; face_mesh.vertices[ 5]=+0.5f;
      face_mesh.vertices[ 6]=+0.5f; face_mesh.vertices[ 7]=-0.5f; face_mesh.vertices[ 8]=-0.5f;
      face_mesh.vertices[ 9]=-0.5f; face_mesh.vertices[10]=-0.5f; face_mesh.vertices[11]=-0.5f;
    break;
  }

  return face_mesh;
}

// VoxelFaceModels ================================================================================================================
@implementation VoxelFaceModels
-(id)init {
  self = [super init];
  if(!self) { return self; }

  Mesh mesh_top    = generateVoxelFaceMesh(VOXEL_FACE_TOP   ); UploadMesh(&mesh_top   , false); top    = LoadModelFromMesh(mesh_top   );
  Mesh mesh_bottom = generateVoxelFaceMesh(VOXEL_FACE_BOTTOM); UploadMesh(&mesh_bottom, false); bottom = LoadModelFromMesh(mesh_bottom);
  Mesh mesh_left   = generateVoxelFaceMesh(VOXEL_FACE_LEFT  ); UploadMesh(&mesh_left  , false); left   = LoadModelFromMesh(mesh_left  );
  Mesh mesh_right  = generateVoxelFaceMesh(VOXEL_FACE_RIGHT ); UploadMesh(&mesh_right , false); right  = LoadModelFromMesh(mesh_right );
  Mesh mesh_front  = generateVoxelFaceMesh(VOXEL_FACE_FRONT ); UploadMesh(&mesh_front , false); front  = LoadModelFromMesh(mesh_front );
  Mesh mesh_back   = generateVoxelFaceMesh(VOXEL_FACE_BACK  ); UploadMesh(&mesh_back  , false); back   = LoadModelFromMesh(mesh_back  );
  return self;
}

-(void)dealloc {
  UnloadModel(top);
  UnloadModel(bottom);
  UnloadModel(left);
  UnloadModel(right);
  UnloadModel(front);
  UnloadModel(back);
  [super dealloc];
}

-(Model*)modelForFace:(int32_t)face {
  switch(face) {
    case VOXEL_FACE_TOP   : return &top;
    case VOXEL_FACE_BOTTOM: return &bottom;
    case VOXEL_FACE_LEFT  : return &left;
    case VOXEL_FACE_RIGHT : return &right;
    case VOXEL_FACE_FRONT : return &front;
    case VOXEL_FACE_BACK  : return &back;
  }
  return NULL;
}
@end
