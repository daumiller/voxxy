#import "toolbar.h"
#import <ObjFW/ObjFW.h>
#include <raygui.h>

// ToolbarItem ====================================================================================================================
@implementation ToolbarItem
-(void)dealloc {
  if(icon) { [icon release]; }
  [super dealloc];
}
-(void)setIconWithCString:(const char*)c_string {
  if(icon) { [icon release]; }
  if(c_string) {
    icon = [[OFString alloc] initWithCString:c_string encoding:OFStringEncodingUTF8];
  } else {
    icon = NULL;
  }
}
-(void)setIcon:(OFString*)icon_string {
  if(icon) { [icon release]; }
  if(icon_string) {
    icon = icon_string;
    [icon_string retain];
  } else {
    icon = NULL;
  }
}
@end

// Toolbar ========================================================================================================================
@implementation Toolbar
-(id)initWithStyle:(ToolbarStyle)style {
  self = [super init];
  if(!self) { return self; }

  delegate    = NULL;
  self->style = style;
  items       = [[OFMutableArray<ToolbarItem*> alloc] init];
  return self;
}
-(void)dealloc {
  [items release];
  [super dealloc];
}

-(void)appendItemWithId:(uint32_t)id Icon:(const char*)icon Visible:(bool)visible Enabled:(bool)enabled Active:(bool)active GroupEnd:(bool)group_end {
  ToolbarItem* item = [[ToolbarItem alloc] init];
  item->id           = id;
  item->icon         = NULL;
  item->is_visible   = visible;
  item->is_enabled   = enabled;
  item->is_active    = active;
  item->is_group_end = group_end;
  [item setIconWithCString:icon];
  [items addObject:item];
  [item release];
}

-(ToolbarItem*)getItemWithId:(uint32_t)id {
  size_t item_count = [items count];
  for(size_t idx=0; idx<item_count; ++idx) {
    ToolbarItem* item = [items objectAtIndex:idx];
    if(item->id == id) { return item; }
  }
  return NULL;
}

-(id)setDelegate:(id <ToolbarDelegate>)delegate {
  id old_delegate = self->delegate;
  self->delegate = delegate;
  return old_delegate;
}

-(void)setSelectedItemId:(uint32_t)id {
  size_t item_count = [items count];
  for(size_t idx=0; idx<item_count; ++idx) {
    ToolbarItem* item = [items objectAtIndex:idx];
    item->is_active = (item->id == id);
  }
}

-(void)renderInRectangle:(Rectangle)rectangle {
  size_t item_count = [items count];

  bool is_horizontal = (rectangle.width >= rectangle.height);
  float size_available = is_horizontal ? rectangle.width : rectangle.height;
  float size_required  = ((float)item_count) * (TOOLBAR_ITEM_SIZE + 2.0f);
  float size_extra     = (size_available > size_required) ? (size_available - size_required) : 0.0f;
  float current_x = rectangle.x + (is_horizontal ? 0.0f : 1.0f);
  float current_y = rectangle.y + (is_horizontal ? 1.0f : 0.0f);

  float space_before  = 1.0f;
  float space_after   = 1.0f;
  uint32_t gap_count  = 0;
  float    gap_amount = 0.0f;

  switch(style) {
    case ToolbarStyle_SpaceAround: {
      float spacing_extra = size_extra / (((float)item_count) + 1.0f);
      space_before += spacing_extra;
      break;
    }
    case ToolbarStyle_SpaceBetween: {
      if(item_count > 1) {
        float spacing_extra = size_extra / (((float)item_count) - 1.0f);
        space_after += spacing_extra;
      }
      break;
    }
    case ToolbarStyle_Centered: {
      if(is_horizontal) {
        current_x += size_extra / 2.0f;
      } else {
        current_y += size_extra / 2.0f;
      }
      break;
    }
    case ToolbarStyle_Grouped: {
      for(size_t idx=0; idx<item_count; ++idx) {
        if(items[idx]->is_group_end) { ++gap_count; }
      }
      gap_amount = size_extra / ((float)gap_count);
      
      break;
    }
  }

  void* pool = objc_autoreleasePoolPush(); // cStringWithEncoding puts allocated memory in ARP... :(
  GuiPanel(rectangle, NULL);
  for(size_t idx=0; idx<item_count; ++idx) {
    ToolbarItem* item = items[idx];
    if(item->is_visible == false) { continue; }

    if(is_horizontal) {
      current_x += space_before;
    } else {
      current_y += space_before;
    }

    int state_before = GuiGetState();
    if(item->is_active) { GuiSetState(GUI_STATE_PRESSED); }
    if(item->is_enabled == false) { GuiSetState(GUI_STATE_DISABLED); }

    if(item->icon) {
      Rectangle button_rectangle = { current_x, current_y, TOOLBAR_ITEM_SIZE, TOOLBAR_ITEM_SIZE };
      if(GuiButton(button_rectangle, [item->icon cStringWithEncoding:OFStringEncodingUTF8])) {
        if(delegate) { [delegate toolbarItemClicked:item]; }
      }
    }
    if(is_horizontal) {
      current_x += TOOLBAR_ITEM_SIZE + space_after;
      if((gap_count > 0) && (item->is_group_end)) { current_x += gap_amount; }
    } else {
      current_y += TOOLBAR_ITEM_SIZE + space_after;
      if((gap_count > 0) && (item->is_group_end)) { current_y += gap_amount; }
    }
    GuiSetState(state_before);
  }
  objc_autoreleasePoolPop(pool);
}
@end
