#include <stdint.h>
#include <stdbool.h>
#include <raylib.h>
#include <ObjFW/ObjFW.h>

#define TOOLBAR_ITEM_SIZE 48.0f

typedef enum {
  ToolbarStyle_SpaceAround,
  ToolbarStyle_SpaceBetween,
  ToolbarStyle_Centered,
  ToolbarStyle_Grouped
} ToolbarStyle;

@interface ToolbarItem : OFObject {
@public
  uint32_t  id;
  OFString* icon;
  bool      is_visible;
  bool      is_enabled;
  bool      is_active;
  bool      is_group_end;
}
-(void)setIconWithCString:(const char*)c_string;
-(void)setIcon:(OFString*)icon_string;
@end

@protocol ToolbarDelegate <OFObject>
-(void)toolbarItemClicked:(ToolbarItem*)toolbar_item;
@end

@interface Toolbar : OFObject {
  id <ToolbarDelegate> delegate;
  ToolbarStyle style;
  OFMutableArray<ToolbarItem*>* items;
}
-(id)initWithStyle:(ToolbarStyle)style;
-(void)appendItemWithId:(uint32_t)id Icon:(const char*)icon Visible:(bool)visible Enabled:(bool)enabled Active:(bool)active GroupEnd:(bool)group_end;
-(ToolbarItem*)getItemWithId:(uint32_t)id;
-(id)setDelegate:(id <ToolbarDelegate>)delegate;
-(void)setSelectedItemId:(uint32_t)id;
-(void)renderInRectangle:(Rectangle)rectangle;
@end
