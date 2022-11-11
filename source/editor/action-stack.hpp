#ifndef ACTION_STACK_HEADER
#define ACTION_STACK_HEADER

#include <vector>
#include "../data/vxx-model.hpp"

typedef enum {
  ActionType_Invalid,
  ActionType_VoxelsAdd,
  ActionType_VoxelsRemove,
  ActionType_VoxelsModify,
} ActionType;

typedef struct {
  std::vector<VxxVoxel> voxels_before;
  std::vector<VxxVoxel> voxels_after;
} ActionData;

typedef struct {
  ActionType type;
  ActionData data;
} Action;

class ActionStack {
public:
  ActionStack();
  ActionStack(int32_t depth_maximum);

  bool canUndo();
  bool canRedo();
  bool isStateSaved();

  void reset();
  void markStateSaved();

  Action undo();
  Action redo();
  void act(Action action);

protected:
  int32_t signedSize();
  int32_t depth_maximum;
  int32_t index_saved;
  int32_t index_current;
  std::vector<Action> actions;
};

#endif // ifndef ACTION_STACK_HEADER
