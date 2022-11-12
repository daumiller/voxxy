#ifndef INTERFACE_COLOR_PICKER_HEADER
#define INTERFACE_COLOR_PICKER_HEADER

#include <stdint.h>
#include <raylib.h>

class ColorPicker {
public:
  void render(Rectangle rectangle);
  void setCurrentColor(uint32_t color);
  // void getPalette(uint32_t* palette_buffer);
  // void setPalette(uint32_t* palette_buffer);

  virtual void onColorChanged(uint32_t color);
  uint32_t current_color;
  // int32_t current_color_palette_index;
  // uint32_t palette[64];
  // bool palette_mode;
};

#endif // ifndef INTERFACE_COLOR_PICKER_HEADER
