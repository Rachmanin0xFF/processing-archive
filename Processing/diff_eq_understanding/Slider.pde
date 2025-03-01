public class Slider {
  float value2; //0.0-1.1
  float value;
  float x;
  float y;
  float w;
  float h;
  float drag_bar_length;
  String name = "";
  boolean horizon;
  color border_color = color(255, 255);
  color fill_color = color(0, 255);
  float radius; //Curve radius on rectangle corners
  boolean display_value;
  float pmouse_x;
  float pmouse_y;
  float deltamouse_x;
  float deltamouse_y;
  boolean dragging;
  boolean only_left_mouse_button = true;
  boolean bad_start = false;
  boolean was_mouse_in_bounds = false;
  boolean was_mouse_pressed = false;
  float minimum = 0.f;
  float maximum = 1.f;
  boolean round_digits = false;
  int digits_to_round_to = 1;
  public Slider(float x, float y, float w, float h) {
    if(w > h) horizon = true;
    drag_bar_length = horizon ? h : w;
    this.x = x; this.y = y;
    this.w = w; this.h = h;
    pmouse_x = mouseX;
    pmouse_y = mouseY;
  }
  public Slider(float x, float y, float w, float h, String name) {
    if(w > h) horizon = true;
    drag_bar_length = horizon ? h : w;
    this.name = name;
    this.x = x; this.y = y;
    this.w = w; this.h = h;
    pmouse_x = mouseX;
    pmouse_y = mouseY;
  }
  public void set_range(float min, float max) {
    minimum = min;
    maximum = max;
  }
  public void set_value(float x) {
    value2 = map(x, minimum, maximum, 0.f, 1.f);
    value = x;
  }
  void update() {
    if(!bad_start && !dragging)
      if(was_mouse_pressed && !was_mouse_in_bounds && is_in_bounds_inclusive(mouseX, mouseY, x, y, w, h))
        bad_start = true;
    if(!mousePressed)
      bad_start = false;
    
    if(!(mousePressed && only_left_mouse_button && mouseButton != LEFT)) {
      deltamouse_x = mouseX - pmouse_x;
      deltamouse_y = mouseY - pmouse_y;
      pmouse_x = mouseX;
      pmouse_y = mouseY;
      boolean b = false;
      if(horizon)
        if(mousePressed && is_in_bounds_inclusive(mouseX, mouseY, map(value2, 0.0f, 1.0f, x, x + w - drag_bar_length), y, drag_bar_length, h))
          dragging = true;
      else
        if(mousePressed && is_in_bounds_inclusive(mouseX, mouseY, x, map(value2, 0.0f, 1.0f, y, y + h - drag_bar_length), w, drag_bar_length))
            dragging = true;
      if(!mousePressed)
        dragging = false;
    }
    
    if(bad_start) dragging = false;
    
    if(dragging) {
      if(horizon)
        value2 += deltamouse_x/(w - drag_bar_length);
    }
    value2 = max(0.0, min(1.0, value2));
    value = map(value2, 0.f, 1.f, minimum, maximum);
    was_mouse_in_bounds = is_in_bounds_inclusive(mouseX, mouseY, x, y, w, h);
    was_mouse_pressed = mousePressed;
  }
  void display() {
    textAlign(CENTER, BOTTOM);
    fill(fill_color);
    stroke(border_color);
    rect(x, y, w, h, radius);
    if(dragging)
      fill(border_color);
    if(horizon) {
      rect(map(value2, 0.0f, 1.0f, x, x + w - drag_bar_length), y, drag_bar_length, h, radius);
      fill(border_color);
      text(name, x + w/2, y + h/2 + 2);
      if(display_value) {
        if(dragging)
          fill(r(fill_color), g(fill_color), b(fill_color), 255);
        textAlign(CENTER, TOP);
        if(round_digits) {
          String s = round_to(map(value2, 0.f, 1.f, minimum, maximum), digits_to_round_to);
          text(s, map(value2, 0.0f, 1.0f, x + drag_bar_length/2, x + w - drag_bar_length/2), y + h/2 + 2);
        } else {
          text(map(value2, 0.f, 1.f, minimum, maximum), map(value2, 0.0f, 1.0f, x + drag_bar_length/2, x + w - drag_bar_length/2), y + h/2 + 2);
        }
      }
    } else {
      rect(x, map(value2, 0.0f, 1.0f, y, y + h - drag_bar_length), w, drag_bar_length, radius);
    }
    textAlign(LEFT, TOP);
  }
  public void set_theme(Theme t) {
    this.fill_color = t.fill_color;
    this.border_color = t.border_color;
    this.radius = t.radius;
  }
}

class Theme {
  color fill_color;
  color border_color;
  float radius = 0.f;
  public Theme(color f, color b) {
    fill_color = f;
    border_color = b;
  }
}

//Digits is the number of digits after the decimal place.
String round_to(float x, int digits) {
  String str = x + "";
  String[] quota = str.split("\\.");
  if(quota.length <= 1) {
    return str;
  }
  quota[1] = quota[1].substring(0, min(quota[1].length(), digits));
  return quota[0] + "." + quota[1];
}

boolean is_in_bounds_inclusive(float x, float y, float x0, float y0, float w, float h) {
  return (x >= x0) && (x <= x0+w) && (y >= y0) && (y <= y0+h);
}

int r(color c) {return (c >> 16) & 255; }
int g(color c) {return (c >> 8) & 255;}
int b(color c) {return c & 255; }
