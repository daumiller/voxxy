#ifndef SELECTION_BUFFER_HEADER
#define SELECTION_BUFFER_HEADER

#include <stdint.h>
#include <raylib.h>
#include <OpenGL/gl3.h>
#define GRAPHICS_API_OPENGL_33
#include <rlgl.h>

typedef struct {
  int32_t voxel_x;
  int32_t voxel_y;
  int32_t voxel_z;
  int32_t voxel_face;
} SelectionBufferId;

class SelectionBuffer {
public:
  SelectionBuffer(const char* vertex_shader_path, const char* fragment_shader_path);
  ~SelectionBuffer();

  void reset(uint32_t width, uint32_t height);
  void bind();
  void unbind();
  SelectionBufferId readIdFromPixel(uint32_t x, uint32_t y);

  Shader shader;
  void setShaderId(SelectionBufferId id);

protected:
  GLuint gl_fbo;
  GLuint gl_texture_color;
  GLuint gl_texture_depth;
  int shader_location_voxel_x;
  int shader_location_voxel_y;
  int shader_location_voxel_z;
  int shader_location_voxel_face;
};

#endif // ifndef SELECTION_BUFFER_HEADER
