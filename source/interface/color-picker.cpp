#include "color-picker.hpp"
#include <stdlib.h>
#include <raygui.h>

static inline Color raylibColorFromUint32(uint32_t uint32_color) {
    return {
      .r = (uint8_t)((uint32_color & 0xFF000000) >> 24),
      .g = (uint8_t)((uint32_color & 0x00FF0000) >> 16),
      .b = (uint8_t)((uint32_color & 0x0000FF00) >>  8),
      .a = (uint8_t)((uint32_color & 0x000000FF) >>  0),
    };
}

static inline uint32_t uint32ColorFromRaylib(Color color) {
  uint32_t output_color = 0;
  output_color |= ((uint32_t)color.r) << 24;
  output_color |= ((uint32_t)color.g) << 16;
  output_color |= ((uint32_t)color.b) <<  8;
  output_color |= ((uint32_t)color.a) <<  0;
  return output_color;
};

// void ColorPicker::getPalette(uint32_t* palette_buffer) {
//   for(uint32_t idx=0; idx<64; ++idx) { palette_buffer[idx] = palette[idx]; }
// }

// void ColorPicker::setPalette(uint32_t* palette_buffer) {
//   for(uint32_t idx=0; idx<64; ++idx) { palette[idx] = palette_buffer[idx]; }
//   setCurrentColor(current_color);
// }

void ColorPicker::onColorChanged(uint32_t color) {
}

void ColorPicker::setCurrentColor(uint32_t color) {
  current_color = color;
  // current_color_palette_index = -1;
  // for(uint32_t idx=0; idx<64; ++idx) {
  //   if(palette[idx] == color) {
  //     current_color_palette_index = idx;
  //     break;
  //   }
  // }
}

void ColorPicker::render(Rectangle rectangle) {
  GuiPanel(rectangle, NULL);

  // Rectangle toggler_rect = rectangle;
  // toggler_rect.width /= 2.0f;
  // toggler_rect.height = 32.0f;
  // if(GuiButton(toggler_rect, "Palette")) { palette_mode = true; }
  // toggler_rect.x += toggler_rect.width;
  // if(GuiButton(toggler_rect, "Free")) { palette_mode = false; }

  // if(palette_mode == false) {
    rectangle.width -= 32.0f;
    // rectangle.y     += 34.0f;
    rectangle.x += 4.0f;
    rectangle.y += 4.0f;
    rectangle.height -= 8.0f;
    Color new_raylib_color = GuiColorPicker(rectangle, "Color Picker", raylibColorFromUint32(current_color));
    uint32_t new_color = uint32ColorFromRaylib(new_raylib_color);
    if(new_color != current_color) {
      current_color = new_color;
      // if(current_color_palette_index > -1) { palette[current_color_palette_index] = new_color; }
      onColorChanged(current_color);
    }
    return;
  // }

  // uint32_t button_base_color_normal    = GuiGetStyle(BUTTON, BASE_COLOR_NORMAL);
  // uint32_t button_base_color_focused   = GuiGetStyle(BUTTON, BASE_COLOR_FOCUSED);
  // uint32_t button_base_color_pressed   = GuiGetStyle(BUTTON, BASE_COLOR_PRESSED);
  // uint32_t button_border_color_focused = GuiGetStyle(BUTTON, BORDER_COLOR_FOCUSED);

  // float palette_x      = rectangle.x +  2.0f;
  // float palette_y      = rectangle.y + 34.0f;
  // float palette_width  = (rectangle.width - 4.0f) / 4.0f;
  // float palette_height = (rectangle.height - 34.0f) / 16.0f;
  // for(uint32_t row=0; row<16; ++row) {
  //   for(uint32_t col=0; col<4; ++col) {
  //     uint32_t idx = (row << 2) + col;

  //     Color current_components = raylibColorFromUint32(palette[idx]);
  //     current_components.r = 255 - current_components.r;
  //     current_components.g = 255 - current_components.g;
  //     current_components.b = 255 - current_components.b;
  //     uint32_t inverse = uint32ColorFromRaylib(current_components);

  //     GuiSetStyle(BUTTON, BASE_COLOR_NORMAL,  palette[idx]);
  //     GuiSetStyle(BUTTON, BASE_COLOR_FOCUSED, palette[idx]);
  //     GuiSetStyle(BUTTON, BASE_COLOR_PRESSED, palette[idx]);
  //     GuiSetStyle(BUTTON, BORDER_COLOR_FOCUSED, inverse);
  //     GuiSetState((current_color_palette_index == idx) ? GUI_STATE_FOCUSED : GUI_STATE_NORMAL);
  //     if(GuiButton({ .x=palette_x + ((float)col * palette_width), .y=palette_y + ((float)row * palette_height), .width=palette_width, .height=palette_height }, " ")) {
  //       current_color = palette[idx];
  //       current_color_palette_index = idx;
  //       onColorChanged(current_color);
  //     }
  //   }
  // }

  // GuiSetStyle(BUTTON, BASE_COLOR_NORMAL,    button_base_color_normal);
  // GuiSetStyle(BUTTON, BASE_COLOR_FOCUSED,   button_base_color_focused);
  // GuiSetStyle(BUTTON, BASE_COLOR_PRESSED,   button_base_color_pressed);
  // GuiSetStyle(BUTTON, BORDER_COLOR_FOCUSED, button_border_color_focused);
}
