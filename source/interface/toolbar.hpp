#ifndef INTERFACE_TOOLBAR_HEADER
#define INTERFACE_TOOLBAR_HEADER

#include <stdint.h>
#include <stdbool.h>
#include <raylib.h>
#include <vector>

#define TOOLBAR_ITEM_SIZE 48.0f

typedef enum {
  ToolbarStyle_SpaceAround,
  ToolbarStyle_SpaceBetween,
  ToolbarStyle_Centered,
  ToolbarStyle_Grouped
} ToolbarStyle;

typedef struct {
  uint32_t    id;
  const char* icon;
  bool  is_visible;
  bool  is_enabled;
  bool  is_active;
  bool  is_group_end;
} ToolbarItem;

class Toolbar {
public:
  Toolbar(ToolbarStyle style);
  void appendItem(ToolbarItem item);
  void appendItems(ToolbarItem* items, int32_t item_count);
  bool insertItem(ToolbarItem item, uint32_t before_item_id);
  bool removeItem(uint32_t item_id);
  ToolbarItem* getItem(uint32_t item_id);
  void render(Rectangle rectangle);
  virtual void onClick(ToolbarItem* item);

protected:
  int32_t getItemIndex(uint32_t item_id);
  ToolbarStyle style;
  std::vector<ToolbarItem> items;
};

#endif // ifndef INTERFACE_TOOLBAR_HEADER
