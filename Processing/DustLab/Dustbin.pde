
import java.awt.Robot;
boolean cursorLock = true;
boolean pcursorLock = true;
void keyPressed() {
  if (key == '\t') {
    cursorLock = !cursorLock;
    if (cursorLock) noCursor();
    else cursor(ARROW);
  } else if (key == 'p') binny.film.to_image_percentile(0.99).save("timpo.png");//binny.film.to_image_simple(true).save("timpo.png");////binny.film.to_image_simple(true).save("timpo.png");
}

double fov = 90.0;
void mouseWheel(MouseEvent me) {
  int e = me.getCount();
  fov *= pow(1.025, -e);
}

int get_surf_x() {
  return get_rectangle(surface).getX();
}
int get_surf_y() {
  return get_rectangle(surface).getY();
}
com.jogamp.nativewindow.util.Rectangle get_rectangle(PSurface surface) {
  com.jogamp.newt.opengl.GLWindow window = (com.jogamp.newt.opengl.GLWindow) surface.getNative();
  com.jogamp.nativewindow.util.Rectangle rectangle = window.getBounds();
  return rectangle;
}

class Dustbin {
  dMat4 proj_mat;
  dMat4 view_mat;

  dVec3 view_tsf; // temp
  dVec3 proj_tsf; // temp

  PImage shark_head;

  dImage film;
  dImage preview_film;
  PImage screen;
  int filmw = 1920*3;
  int filmh = 1080*3;
  boolean previewing = true;
  boolean was_previewing = true;
  boolean DoF = true;
  boolean z_test = false;
  int DoF_mode = 0; // 0 - jitter points around; 1 - draw circle
  dVec3 r;
  dVec3 cc;
  Robot rob;
  double aspect;

  double cam_vel = 1.0;
  dVec3 pos;
  double yaw = 0.0;
  double pitch = 0.0;
  dVec3[] qqq;
  Dustbin() {
    proj_mat = perspective_mat(0.1, 10000.0, PI*2, 1.0);
    view_mat = new dMat4();
    film = new dImage(filmw, filmh);
    aspect = (double)filmw/(double)filmh;
    println(aspect);
    float ratio = (float)filmw/(float)filmh;
    preview_film = new dImage(round(ratio*256), 256);
    pos = new dVec3(0, 0, 30);

    r = new dVec3(0, 1, 0);
    cc = new dVec3(0, 0, 0);
    qqq = new dVec3[100];
    for (int i = 0; i < qqq.length; i++) {
      qqq[i] = new dVec3(random(-200, 200), random(-200, 200), random(-200, 200));
    }
    try {
      rob = new Robot();
    }
    catch(Exception e) {
    }
    load_camera();
    if(cursorLock) noCursor();
    shark_head = loadImage("shark_head.png");
  }

  void box(double x, double y, double z, double r) {
    for (double k = -r; k < r; k+=random(0.9, 1.1)*r/(previewing?20.0:1000.0)) {
      hit_photon(x-r, y-r, z+k);
      hit_photon(x+r, y-r, z+k);
      hit_photon(x+r, y+r, z+k);
      hit_photon(x-r, y+r, z+k);
      hit_photon(x-r, y+k, z-r);
      hit_photon(x+r, y+k, z-r);
      hit_photon(x+r, y+k, z+r);
      hit_photon(x-r, y+k, z+r);
      hit_photon(x+k, y-r, z-r);
      hit_photon(x+k, y+r, z-r);
      hit_photon(x+k, y+r, z+r);
      hit_photon(x+k, y-r, z+r);
    }
  }
  void save_camera() {
    String[] s = new String[]{pos.x + "o" + pos.y + "o" + pos.z, yaw + "", pitch + "", fov + "", cursorLock?"true":"false"};
    saveStrings("camera_pos.txt", s);
    //println(pos.x + "," + pos.y + "," + pos.z + " " + yaw + " " + pitch + " " + fov);
  }
  void load_camera() {
    String[] s = loadStrings("camera_pos.txt");
    if(s == null) return;
    String[] psplit = s[0].split("o");
    pos.x = Double.parseDouble(psplit[0]);
    pos.y = Double.parseDouble(psplit[1]);
    pos.z = Double.parseDouble(psplit[2]);
    yaw = Double.parseDouble(s[1]);
    pitch = Double.parseDouble(s[2]);
    fov = Double.parseDouble(s[3]);
    cursorLock = s[4]=="true";
    pcursorLock = cursorLock;
    println(pos.x + "," + pos.y + "," + pos.z + " " + yaw + " " + pitch + " " + fov);
  }
  double znear = 1.0;
  double zfar = 10000.0;
  void update() {
    previewing = cursorLock;

    proj_mat = perspective_mat(znear, zfar, fov*0.01745329251, (float)filmw/(float)filmh);
    view_mat = new dMat4();

    if (cursorLock) {
      if (pcursorLock) {
        pitch += (mouseY - height/2)/200.0;
        yaw -= (mouseX - width/2)/200.0;
      }
      rob.mouseMove(width/2 + get_surf_x(), height/2 + get_surf_y());
      if (pitch > PI/2.0) pitch = PI/2.0;
      if (pitch < -PI/2.0) pitch = -PI/2.0;
    }
    pcursorLock = cursorLock;
    view_mat.rotateX(pitch);
    view_mat.rotateY(yaw);

    dVec3 fw = new dVec3(0, 0, 1.0);
    dVec3 rt = new dVec3(cam_vel, 0.0, 0.0);
    fw.rotateX(-pitch);
    fw.rotateY(yaw);
    rt.rotateY(yaw);
    //fw.y = 0;
    //fw.normalize();
    fw.mult(cam_vel);
    if (cursorLock && keyPressed) {
      if (key == 'w') pos.add(fw);
      if (key == 's') pos.sub(fw);
      if (key == 'd') pos.add(rt);
      if (key == 'a') pos.sub(rt);
      if (key == ' ') pos.add(new dVec3(0.0, -cam_vel, 0.0));
      if (keyCode == SHIFT) pos.add(new dVec3(0.0, cam_vel, 0.0));
    }
    view_mat.translate(pos.x, pos.y, pos.z);
    
    save_camera(); 

    if (previewing) {
      preview_film.clear();
      if (!was_previewing) film.clear();

      for (int i = 0; i < qqq.length; i++) {
        box(qqq[i].x, qqq[i].y, qqq[i].z, 2.5);
      }
    }
    was_previewing = previewing;

    double sigma = 10.0;
    double beta = 8.0/3.0;
    double rho = 85.5;
    
    dVec3[] cca = new dVec3[]{new dVec3(0.1, 0.5, 1.0), new dVec3(0.5, 1.0, 0.1), new dVec3(1.0, 0.1, 0.7), new dVec3(0.8, 0.3, 1.0)};

    //int photons_per_frame = 2000000;
    long photons_per_frame = 10000000;
    if (previewing) photons_per_frame = 5000;

    long photon_count_0 = previewing ? preview_film.count : film.count;
    long photon_count = 0;
    
    cc = new dVec3(1.0, 0.1, 0.01);
    
    int k = 0;
    r = new dVec3(randomGaussian(), randomGaussian(), randomGaussian());
    //r.normalize();
    
    float scrd = 30.0;
    //dVec3 konst = new dVec3(0.2, -0.1, 0.3);
    boolean show = false;
    
    
    
    PVector[] pts = new PVector[]{new PVector(2, 4, -10), new PVector(0, 10, 4), new PVector(-2, -7, -3), new PVector(1, -8, 10)};
    PVector[] clrs = new PVector[]{new PVector(2, 4, 7), new PVector(3, 10, 5), new PVector(9, 7, 4), new PVector(7, 1, 8)};
    
    PVector C = new PVector(0,0,0);
    PVector E = new PVector(0,5);
    while (photon_count < photons_per_frame && k < 10000000) {
      
      int choice=(int)random(0,4);
     E.add(pts[choice]);
     E.mult(0.5);
     float f=0.5;
     C.add(PVector.mult(clrs[choice], f));
     C.mult(1.0/(1+f));
     //glow
     if(random(10)>9) E.add(new PVector(random(-1, 1), random(-1, 1), random(-1, 1)));
     //TANTHAPUS MODE
     switch(choice)
      {
        case 0:
        E = new PVector((sin(E.y)+2*E.y),((cos(E.x)-E.x)), cos(E.z + 0.1) - E.z);
        break;
        case 1:
        E.y = sqrt(abs(E.x*E.y*E.z))-E.x;
        break;
        //BRINGER OF TANTH
        case 3:
        E.x = tanh(2*E.z)-E.y;
        E.y = tanh(2*E.x)-E.z;
        E.z = tanh(2*E.y)-E.x;
        break;
      }
        
      hit_photon(E.x*scrd, E.y*scrd, E.z*scrd, C.x, C.y, C.z);
      
      cc = lerp(cc, new dVec3(0.01, 0.1, 1.0), 0.01);
      
      photon_count = previewing ? preview_film.count : film.count;
      photon_count -= photon_count_0;
      k++;
    }
    if (previewing) {
      screen = preview_film.to_image_MAX();
    } else {
      screen = film.to_image_simple(false);
      //screen = film.to_image_percentile(0.99);
    }
  }

  double noisea(double x, double y, double z) {
    return 3.0*(noise((float)x, (float)y, (float)z)-0.5);
  }
  
  void translate(double x, double y, double z) {
    view_mat.translate(x, y, z);
  }
  void rotateX(double t) {
    view_mat.rotateX(t);
  }
  void rotateY(double t) {
    rotateY(t);
  }
  
  void hit_photon(double x, double y, double z, double r, double b, double g) {
    hit_photon(new dVec3(x, y, z), new dVec3(r, g, b));
  }
  
  void hit_photon(double x, double y, double z) {
    hit_photon(new dVec3(x, y, z), new dVec3(10.0, 10.0, 10.0));
  }

  double aperture = 1.8;//0.5;
  double plane_in_focus = 40;
  void hit_photon(dVec3 v, dVec3 col) {
    plane_in_focus = pos.mag();
    view_tsf = view_mat.mult(v);
    proj_tsf = proj_mat.mult(view_tsf);
    double w = proj_mat.mult_get_w(view_tsf);
    double depth = -view_tsf.z;
    if (depth > znear) {
      if (previewing) preview_film.hit_photon_linear_01(proj_tsf.x/w, proj_tsf.y/w, col.x, col.y, col.z);
      else {
        double falloff = 1/(depth*depth);
        if (DoF) {
          double CoC = Math.abs(aperture*(depth-plane_in_focus)/(depth*(plane_in_focus-1)));
          if (DoF_mode == 0) {
            double x = 1;
            double y = 1;
            while (x*x + y*y > 1.0) {
              x = random(-1, 1);
              y = random(-1, 1);
            }
            film.hit_photon_linear_01(proj_tsf.x/w + x*CoC, proj_tsf.y/w + aspect*y*CoC, col.x*falloff, col.y*falloff, col.z*falloff);
          } else film.hit_photon_DoF(proj_tsf.x/w, proj_tsf.y/w, col.x*falloff, col.y*falloff, col.z*falloff, CoC);
        } else {
          if (z_test) {
            film.hit_photon_z_01(proj_tsf.x/w, proj_tsf.y/w, depth, col.x, col.y, col.z);
          } else {
            film.hit_photon_linear_01(proj_tsf.x/w, proj_tsf.y/w, col.x*falloff, col.y*falloff, col.z*falloff);
          }
        }
      }
    }
  }
  
  void draw_histo(float x, float y, float w, float h, int bins) {
    fill(0, 255);
    //noStroke();
    //rect(x, y, w, h);
    int[][] hsti = histo(film.px, bins, 8);
    float[][] hst = new float[bins][3];
    for (int i = 0; i < hst.length; i++) {
      for (int j = 0; j < 3; j++)
        hst[i][j] = log(1.0*hsti[i][j]+1.0);
    }
    float min = Float.MAX_VALUE;
    float max = -Float.MAX_VALUE;
    for (int i = 0; i < hst.length; i++) {
      if (hst[i][0] < min) min = hst[i][0];
      if (hst[i][1] < min) min = hst[i][1];
      if (hst[i][2] < min) min = hst[i][2];
      if (hst[i][0] > max) max = hst[i][0];
      if (hst[i][1] > max) max = hst[i][1];
      if (hst[i][2] > max) max = hst[i][2];
    }
    float wid = w/bins;
    blendMode(ADD);
    for (int i = 0; i < hst.length; i++) {
      float xp = x + i*wid;
      float yp = y + h;
      stroke(255, 0, 0);
      rect(xp, yp, wid, -map(hst[i][0], min, max, 0, h));
      stroke(0, 255, 0);
      rect(xp, yp, wid, -map(hst[i][1], min, max, 0, h));
      stroke(0, 0, 255);
      rect(xp, yp, wid, -map(hst[i][2], min, max, 0, h));
    }
    blendMode(BLEND);
  }
  
  void clear_film() {
    film.clear();
  }
}




/*
BACKUP
int photon_count_0 = previewing ? preview_film.count : film.count;
    int photon_count = 0;
    dVec3 v1 = new dVec3(1, 0, -0.7);
    dVec3 v2 = new dVec3(-1, 0, -0.7);
    dVec3 v3 = new dVec3(0, 1, 0.7);
    dVec3 v4 = new dVec3(0, -1, 0.7);

    dVec3 c1 = new dVec3(0.05, 1.0, 0.3);
    dVec3 c2 = new dVec3(0.2, 0.3, 1.0);
    dVec3 c3 = new dVec3(1.0, 0.15, 0.1);
    dVec3 c4 = new dVec3(1.0, 0.4, 0.9);
    dVec3 c5 = new dVec3(0.7, 0.5, 0.2);
    
    int k = 0;
    r = new dVec3(randomGaussian(), randomGaussian(), randomGaussian());
    while (photon_count < photons_per_frame && k < 1000000) {
      dVec3 vv = new dVec3();

      if (random(4) > 3) {
        vv = new dVec3(v1);
        cc = lerp(cc, c1, 0.2);
        r = lerp(r, vv, 1.0/2.0);
      } else if (random(3) > 2) {
        vv = new dVec3(v2);
        cc = lerp(cc, c2, 0.2);
        r = lerp(r, vv, 1.0/2.0);
      } else if (random(2) > 1) {
        vv = new dVec3(v3);
        cc = lerp(cc, c3, 0.2);
        r = lerp(r, vv, 1.0/2.0);
      } else {
         vv = new dVec3(v4);
         cc = lerp(cc, c4, 0.2);
         r = lerp(r, vv, 1.0/2.0);
      }
      
      double rm = r.mag2();
      if(random(2) > 1) {
        //r.normalize();
      }
      
      r.rotateY(0.1*rm);
      //r.normalize();
      r.rotateX(0.5/rm);
      //r.mult(rm*0.9);
      r.rotateX(r.x*0.1);


    float scrd = 30.0;
    hit_photon(r.x*scrd, r.y*scrd, r.z*scrd, cc.x, cc.y, cc.z);
    photon_count = previewing ? preview_film.count : film.count;
    photon_count -= photon_count_0;
    k++;
  }
  if (previewing) {
    screen = preview_film.to_image_MAX();
  } else {
    screen = film.to_image_simple(false);
  }
  */
