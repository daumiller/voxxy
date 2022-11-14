#import <ObjFW/ObjFW.h>
#import "editor-state.h"
#import "voxel-face-models.h"
#import "../rendering/selection-buffer.h"

@interface Editor : OFObject {
  EditorInterfaceState* state_of_interface;
  EditorDataState*      state_of_data;
  VoxelFaceModels*      voxel_face_models;
  SelectionBuffer*      selection_buffer;
}
-(void)loop;
@end
