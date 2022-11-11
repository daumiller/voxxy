#include "action-stack.hpp"

// index_current is the index of the just-performed action; so,
//    (index_current == -1) => no actions have been performed
//    (index_current == 0)  => action at index 0 was just performed
// index_saved is the index of which action was performed just before saving
//    (index_saved == -1) => never been saved (or saved in some pushed-out-by-overflow action)
//    (index_saved == 0) => state was saved immediately after performing the first action

// don't use this... need a default ctor because c++ is fucking annoying
ActionStack::ActionStack() {
  depth_maximum = 1;
  this->reset();
}

ActionStack::ActionStack(int32_t depth_maximum) {
  this->depth_maximum = depth_maximum;
  this->reset();
}

bool ActionStack::canUndo()      { return (index_current > -1);                 }
bool ActionStack::canRedo()      { return (index_current < (signedSize() - 1)); }
bool ActionStack::isStateSaved() { return (index_current == index_saved);       }

void ActionStack::reset() {
  std::vector<Action> actions_new;
  actions       = actions_new;
  index_saved   = -2;
  index_current = -1;
}

void ActionStack::markStateSaved() {
  index_saved = index_current;
}

Action ActionStack::undo() {
  if(index_current < 0) {
    Action blank_action;
    blank_action.type = ActionType_Invalid;
    return blank_action;
  }

  Action undo_action = actions[index_current];
  --index_current;
  return undo_action;
}

Action ActionStack::redo() {
  if(index_current >= (signedSize() - 1)) {
    Action blank_action;
    blank_action.type = ActionType_Invalid;
    return blank_action;
  }

  ++index_current;
  return actions[index_current];
}

void ActionStack::act(Action action) {
  size_t x = 0;
  if(index_current <= (signedSize() - 2 )) {
    // we re-did some thing(s), and now performed a new action at that location,
    // dismiss all further actions (redos) that used to come after this position
    actions.erase(actions.begin() + index_current, actions.end());
  }
  if(signedSize() == depth_maximum) {
    // if we're at maximum depth, remove the first element,
    // and adjust the save point accordingly
    // (save point may now be unreachable)
    actions.erase(actions.begin());
    --index_saved;
  }
  actions.push_back(action);
}

inline int32_t ActionStack::signedSize() {
  return ((int32_t)actions.size());
}
