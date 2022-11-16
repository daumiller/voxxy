#import <ObjFW/ObjFW.h>
#include <stdint.h>
#include <OpenGL/gl3.h>
#define GRAPHICS_API_OPENGL_33
#include <raylib.h>
#include <rlgl.h>

typedef struct {
  int32_t voxel_x;
  int32_t voxel_y;
  int32_t voxel_z;
  int32_t voxel_face;
} SelectionBufferId;

bool selectionBufferIds_sameVoxel(SelectionBufferId* selection_a, SelectionBufferId* selection_b);
bool selectionBufferIds_sameFace(SelectionBufferId* selection_a, SelectionBufferId* selection_b);

@interface SelectionBuffer : OFObject {
@public
  Shader shader;
  GLuint gl_fbo;
  GLuint gl_texture_color;
  GLuint gl_texture_depth;
  int shader_location_voxel_x;
  int shader_location_voxel_y;
  int shader_location_voxel_z;
  int shader_location_voxel_face;
}
-(id)initWithShaderVertex:(const char*)vertex_shader_path Fragment:(const char*)fragment_shader_path;
-(void)resizeWidth:(uint32_t)width Height:(uint32_t)height;
-(void)bind;
-(void)unbind;
-(SelectionBufferId)readIdFromPixelX:(uint32_t)x Y:(uint32_t)y;
-(void)setShaderId:(SelectionBufferId)id;
-(void)setShaderIdX:(int32_t)voxel_x Y:(int32_t)voxel_y Z:(int32_t)voxel_z Face:(int32_t)voxel_face;
@end
