#import "selection-buffer.h"
#include <stdio.h>
#include <stdlib.h>

bool selectionBufferIds_sameVoxel(SelectionBufferId* selection_a, SelectionBufferId* selection_b) {
  return (selection_a->voxel_x == selection_b->voxel_x) &&
         (selection_a->voxel_y == selection_b->voxel_y) &&
         (selection_a->voxel_z == selection_b->voxel_z) ;
}

bool selectionBufferIds_sameFace(SelectionBufferId* selection_a, SelectionBufferId* selection_b) {
  return (selection_a->voxel_x    == selection_b->voxel_x   ) &&
         (selection_a->voxel_y    == selection_b->voxel_y   ) &&
         (selection_a->voxel_z    == selection_b->voxel_z   ) &&
         (selection_a->voxel_face == selection_b->voxel_face) ;
}

@implementation SelectionBuffer
-(id)initWithShaderVertex:(const char*)vertex_shader_path Fragment:(const char*)fragment_shader_path {
  self = [super init];
  if(!self) { return self; }

  gl_fbo           = 0;
  gl_texture_color = 0;
  gl_texture_depth = 0;

  shader = LoadShader(vertex_shader_path, fragment_shader_path);
  shader_location_voxel_x    = GetShaderLocation(shader, "voxel_x");
  shader_location_voxel_y    = GetShaderLocation(shader, "voxel_y");
  shader_location_voxel_z    = GetShaderLocation(shader, "voxel_z");
  shader_location_voxel_face = GetShaderLocation(shader, "voxel_face");

  return self;
}

-(void)dealloc {
  if(gl_fbo          ) { glDeleteFramebuffers(1, &gl_fbo      ); }
  if(gl_texture_color) { glDeleteTextures(1, &gl_texture_color); }
  if(gl_texture_depth) { glDeleteTextures(1, &gl_texture_depth); }
  [super dealloc];
}

-(void)resizeWidth:(uint32_t)width Height:(uint32_t)height {
  if(gl_fbo          ) { glDeleteFramebuffers(1, &gl_fbo      ); }
  if(gl_texture_color) { glDeleteTextures(1, &gl_texture_color); }
  if(gl_texture_depth) { glDeleteTextures(1, &gl_texture_depth); }

  glGenFramebuffers(1, &gl_fbo);
  glBindFramebuffer(GL_FRAMEBUFFER, gl_fbo);

  glGenTextures(1, &gl_texture_color);
  glBindTexture(GL_TEXTURE_2D, gl_texture_color);
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA32I, width, height, 0, GL_RGBA_INTEGER, GL_INT, NULL);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
  glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, gl_texture_color, 0);

  glGenTextures(1, &gl_texture_depth);
  glBindTexture(GL_TEXTURE_2D, gl_texture_depth);
  glTexImage2D(GL_TEXTURE_2D, 0, GL_DEPTH_COMPONENT, width, height, 0, GL_DEPTH_COMPONENT, GL_FLOAT, NULL);
  glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_TEXTURE_2D, gl_texture_depth, 0);

  GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
  if(status != GL_FRAMEBUFFER_COMPLETE) {
    fprintf(stderr, "SelectionBuffer GL Error: 0x%x\n", status);
    exit(-1);
  }

  [self unbind];
}

-(void)bind {
  glBindFramebuffer(GL_DRAW_FRAMEBUFFER, gl_fbo);
}

-(void)unbind {
  glBindTexture(GL_TEXTURE_2D, 0);
  glBindFramebuffer(GL_FRAMEBUFFER, 0);
}

-(SelectionBufferId)readIdFromPixelX:(uint32_t)x Y:(uint32_t)y {
  glBindFramebuffer(GL_READ_FRAMEBUFFER, gl_fbo);
  glReadBuffer(GL_COLOR_ATTACHMENT0);
  int32_t pixel_values[4];
  glReadPixels(x, y, 1, 1, GL_RGBA_INTEGER, GL_INT, pixel_values);
  glReadBuffer(GL_NONE);
  glBindFramebuffer(GL_READ_FRAMEBUFFER, 0);

  SelectionBufferId result = {
    .voxel_x=pixel_values[0],
    .voxel_y=pixel_values[1],
    .voxel_z=pixel_values[2],
    .voxel_face=pixel_values[3]
  };
  return result;
}

-(void)setShaderId:(SelectionBufferId)id {
  [self setShaderIdX:id.voxel_x Y:id.voxel_y Z:id.voxel_z Face:id.voxel_face];
}

-(void)setShaderIdX:(int32_t)voxel_x Y:(int32_t)voxel_y Z:(int32_t)voxel_z Face:(int32_t)voxel_face {
  SetShaderValue(shader, shader_location_voxel_x,    &voxel_x,    SHADER_UNIFORM_INT);
  SetShaderValue(shader, shader_location_voxel_y,    &voxel_y,    SHADER_UNIFORM_INT);
  SetShaderValue(shader, shader_location_voxel_z,    &voxel_z,    SHADER_UNIFORM_INT);
  SetShaderValue(shader, shader_location_voxel_face, &voxel_face, SHADER_UNIFORM_INT);
}
@end
