#import "editor/editor.h"

int main(int argc, char** argv) {
  Editor* editor = [[Editor alloc] init];
  [editor loop];
  [editor release];
  return 0;
}
