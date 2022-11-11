#include "toolbar.hpp"
#include <string.h>
#include <raygui.h>

Toolbar::Toolbar(ToolbarStyle style) {
  this->style = style;
}

void Toolbar::appendItem(ToolbarItem item) {
  items.push_back(item);
}

void Toolbar::appendItems(ToolbarItem* items, int32_t item_count) {
  for(uint32_t idx=0; idx<item_count; ++idx) {
    this->items.push_back(*items);
    ++items;
  }
}

bool Toolbar::insertItem(ToolbarItem item, uint32_t before_item_id) {
  int32_t before_index = getItemIndex(before_item_id);
  if(before_index < 0) { return false; }
  items.insert(items.begin() + before_index, item);
  return true;
}

bool Toolbar::removeItem(uint32_t item_id) {
  int32_t index = getItemIndex(item_id);
  if(index < 0) { return false; }
  items.erase(items.begin() + index);
  return true;
}

int32_t Toolbar::getItemIndex(uint32_t item_id) {
  size_t count = items.size();
  for(size_t idx=0; idx<count; ++idx) {
    if(items[idx].id == item_id) { return (int32_t)idx; }
  }
  return -1;
}

ToolbarItem* Toolbar::getItem(uint32_t item_id) {
  int32_t index = getItemIndex(item_id);
  if(index < 0) { return NULL; }
  return &(items[index]);
}

void Toolbar::render(Rectangle rectangle) {
  if(rectangle.width  < 1.0f) { rectangle.width  = TOOLBAR_ITEM_SIZE + 2.0f; }
  if(rectangle.height < 1.0f) { rectangle.height = TOOLBAR_ITEM_SIZE + 2.0f; }
  uint32_t item_count = (uint32_t)(items.size());

  bool is_horizontal   = rectangle.width >= rectangle.height;
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
      for(uint32_t idx=0; idx<item_count; ++idx) {
        if(items[idx].is_group_end) { ++gap_count; }
      }
      gap_amount = size_extra / ((float)gap_count);
      break;
    }
  }

  GuiPanel(rectangle, NULL);
  for(uint32_t idx=0; idx<item_count; ++idx) {
    ToolbarItem* item = &(items[idx]);
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
      if(GuiButton({ current_x, current_y, TOOLBAR_ITEM_SIZE, TOOLBAR_ITEM_SIZE}, item->icon)) {
        onClick(item);
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
}

void Toolbar::onClick(ToolbarItem* item) {
  // default to no-op
}
