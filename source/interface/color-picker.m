#import "color-picker.h"
#include <raygui.h>

// Helpers ========================================================================================================================
static inline Color raylibColorFromUint32(uint32_t uint32_color) {
  Color raylib_color = {
    .r = (uint8_t)((uint32_color & 0xFF000000) >> 24),
    .g = (uint8_t)((uint32_color & 0x00FF0000) >> 16),
    .b = (uint8_t)((uint32_color & 0x0000FF00) >>  8),
    .a = (uint8_t)((uint32_color & 0x000000FF) >>  0),
  };
  return raylib_color;
}

static inline uint32_t uint32ColorFromRaylib(Color color) {
  uint32_t output_color = 0;
  output_color |= ((uint32_t)color.r) << 24;
  output_color |= ((uint32_t)color.g) << 16;
  output_color |= ((uint32_t)color.b) <<  8;
  output_color |= ((uint32_t)color.a) <<  0;
  return output_color;
};

// ColorPicker ====================================================================================================================
@implementation ColorPicker
-(id)init {
  self = [super init];
  if(!self) { return self; }

  delegate = NULL;
  color    = 0xFFFFFFFF;
  return self;
}

-(id)setDelegate:(id <ColorPickerDelegate>)delegate {
  id <ColorPickerDelegate> old_delegate = self->delegate;
  self->delegate = delegate;
  return old_delegate;
}

-(uint32_t)getColor {
  return color;
}

-(void)setColor:(uint32_t)color {
  self->color = color;
}

-(void)renderInRectangle:(Rectangle)rectangle {
  GuiPanel(rectangle, NULL);

  // when using GuiColorPicker(), the gradient component is rendered using the given rectangle,
  // and the slider to the side is rendered completely OUTSIDE of the given rectangle... :(
  rectangle.width -= 32.0f;
  // these other adjustments are just to add some padding within the panel
  rectangle.x += 4.0f;
  rectangle.y += 4.0f;
  rectangle.height -= 8.0f;

  Color new_raylib_color = GuiColorPicker(rectangle, "Color Picker", raylibColorFromUint32(color));
  uint32_t new_uint32_color = uint32ColorFromRaylib(new_raylib_color);
  if(new_uint32_color != color) {
    color = new_uint32_color;
    if(delegate) { [delegate colorChanged:color]; }
  }
}
@end
