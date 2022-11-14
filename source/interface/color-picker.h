#import <ObjFW/ObjFW.h>
#include <stdint.h>
#include <raylib.h>

@protocol ColorPickerDelegate <OFObject>
-(void)colorChanged:(uint32_t)color;
@end

@interface ColorPicker : OFObject {
  id <ColorPickerDelegate> delegate;
  uint32_t color;
}
-(id)setDelegate:(id <ColorPickerDelegate>)delegate;
-(uint32_t)getColor;
-(void)setColor:(uint32_t)color;
-(void)renderInRectangle:(Rectangle)rectangle;
@end
