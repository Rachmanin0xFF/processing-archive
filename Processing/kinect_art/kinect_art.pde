/* --------------------------------------------------------------------------
 * SimpleOpenNI Hands3d Test
 * --------------------------------------------------------------------------
 * Processing Wrapper for the OpenNI/Kinect 2 library
 * http://code.google.com/p/simple-openni
 * --------------------------------------------------------------------------
 * prog:  Max Rheiner / Interaction Design / Zhdk / http://iad.zhdk.ch/
 * date:  12/12/2012 (m/d/y)
 * ----------------------------------------------------------------------------
 * This demos shows how to use the gesture/hand generator.
 * It's not the most reliable yet, a two hands example will follow
 * ----------------------------------------------------------------------------
 */
 
import java.util.Map;
import java.util.Iterator;

import SimpleOpenNI.*;

SimpleOpenNI context;
int handVecListSize = 20;
Map<Integer,ArrayList<PVector>>  handPathList = new HashMap<Integer,ArrayList<PVector>>();
color[]       userClr = new color[]{ color(255,0,0),
                                     color(0,255,0),
                                     color(0,0,255),
                                     color(255,255,0),
                                     color(255,0,255),
                                     color(0,255,255)
                                   };
void setup() {
  frameRate(100000);
  size(640*2, 480*2);
  context = new SimpleOpenNI(this);
  if(context.isInit() == false) {
     println("Can't init SimpleOpenNI, maybe the camera is not connected!"); 
     exit();
     return;  
  }   
  context.enableDepth();
  context.setMirror(true);
  context.enableHand();
  context.startGesture(SimpleOpenNI.GESTURE_WAVE);
  background(0);
}

void draw() {
  context.update();
  if(!keyPressed) background(0);
  //image(context.depthImage(),0,0, 640*2, 480*2);
  
  if(handPathList.size() > 0) {    
    Iterator itr = handPathList.entrySet().iterator();     
    while(itr.hasNext()) {
      Map.Entry mapEntry = (Map.Entry)itr.next(); 
      int handId = (Integer)mapEntry.getKey();
      ArrayList<PVector> vecList = (ArrayList<PVector>)mapEntry.getValue();
      PVector p;
      PVector p2d = new PVector();
      stroke(0, 255, 0);
      noFill(); 
      strokeWeight(1);        
      Iterator itrVec = vecList.iterator(); 
      beginShape();
      while(itrVec.hasNext()) { 
        p = (PVector)itrVec.next(); 
        context.convertRealWorldToProjective(p,p2d);
        curveVertex(p2d.x*2, p2d.y*2);
      }
      endShape();   
      stroke(0, 255, 0);
      strokeWeight(10);
      p = vecList.get(0);
      context.convertRealWorldToProjective(p,p2d);
      point(p2d.x*2, p2d.y*2);
 
    }        
  }
}


// -----------------------------------------------------------------
// hand events

void onNewHand(SimpleOpenNI curContext,int handId,PVector pos)
{
  println("onNewHand - handId: " + handId + ", pos: " + pos);
 
  ArrayList<PVector> vecList = new ArrayList<PVector>();
  vecList.add(pos);
  
  handPathList.put(handId,vecList);
}

void onTrackedHand(SimpleOpenNI curContext,int handId,PVector pos)
{
  //println("onTrackedHand - handId: " + handId + ", pos: " + pos );
  
  ArrayList<PVector> vecList = handPathList.get(handId);
  if(vecList != null)
  {
    vecList.add(0,pos);
    if(vecList.size() >= handVecListSize)
      // remove the last point 
      vecList.remove(vecList.size()-1); 
  }  
}

void onLostHand(SimpleOpenNI curContext,int handId)
{
  println("onLostHand - handId: " + handId);
  handPathList.remove(handId);
}

// -----------------------------------------------------------------
// gesture events

void onCompletedGesture(SimpleOpenNI curContext,int gestureType, PVector pos)
{
  println("onCompletedGesture - gestureType: " + gestureType + ", pos: " + pos);
  
  int handId = context.startTrackingHand(pos);
  println("hand stracked: " + handId);
}
