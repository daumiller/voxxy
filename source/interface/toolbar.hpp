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
  const char* id;
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
  bool insertItem(ToolbarItem item, const char* before_item_id);
  bool removeItem(const char* id);
  ToolbarItem* getItem(const char* id);
  void render(Rectangle rectangle);
  virtual void onClick(ToolbarItem* item);

protected:
  int32_t getItemIndex(const char* id);
  ToolbarStyle style;
  std::vector<ToolbarItem> items;
};

#endif // ifndef INTERFACE_TOOLBAR_HEADER
