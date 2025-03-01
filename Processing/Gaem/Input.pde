
void initInput() {
  initKeyTracker();
  IE = new InputEvents();
}
void updateInput() {
  IE.update(gameSettings);
}

HashMap<Character, Boolean> keyStates=new HashMap<Character, Boolean>();
HashMap<Integer, Boolean> keyCodeStates=new HashMap<Integer, Boolean>();
void initKeyTracker() {
  int[]temp_key_codes={UP, RIGHT, DOWN, LEFT, SHIFT};
  char[]temp_keys={'w', 's', 'a', 'd', 'W', 'A', 'S', 'D'};
  
  for (char c : temp_keys) {
    keyStates.put(c, false);
  }

  for (int c : temp_key_codes) {
    keyCodeStates.put(c, false);
  }
}
InputEvents IE;
class InputEvents {
  boolean u = false;
  boolean r = false;
  boolean d = false;
  boolean l = false;
  void update(SettingsHandler se) {
    u = keyCodeStates.get((int)se.getSetting("up_key"));
    r = keyCodeStates.get((int)se.getSetting("right_key"));
    d = keyCodeStates.get((int)se.getSetting("down_key"));
    l = keyCodeStates.get((int)se.getSetting("left_key"));
  }
}
void keyPressed() {
  if (key!=CODED)
    keyStates.put(key, true);
  else
    keyCodeStates.put(keyCode, true);
}

void keyReleased() {
  if (key!=CODED)
    keyStates.put(key, false);
  else 
    keyCodeStates.put(keyCode, false);
}