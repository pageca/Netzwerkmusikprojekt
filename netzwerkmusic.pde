import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress superCollider;

float x,y = 0;

void settings() {
  oscP5 = new OscP5(this, 12000);
  superCollider = new NetAddress("127.0.0.1", 57120);

  size(800, 800);
}



void setup(){
  
  background(0,0,0);

}


void draw(){

  float r = 0;
  float g = map(y, 0, 1, 0, 255);
  float b = map(x, 0, 1, 0, 255);
  background(r, g, b);
  
  
  stroke(200,0,0);
  fill(100,0,0);
  ellipseMode(CENTER);
  ellipse(width/2, height/2, x*width, y* height);
  
  stroke(0);
  fill(255);
  
  //millis();
  float xPoint = x*width;
  float yPoint = (1-y)*height;
  float triSize = 15;
  
  translate(xPoint+(triSize/2),yPoint-(triSize/2));
  rotate(millis()/1000.0*2*PI*x*5);
  //triangle(xPoint, yPoint,xPoint+triSize,yPoint,xPoint+(triSize/2),yPoint-triSize);
  triangle(triSize*-0.5, triSize*0.5, triSize*0.5, triSize*0.5, 0, -sqrt(0.5)*triSize);
}

void mouseClicked(){

  sendOscMsg();

}


void sendOscMsg(){
  
  OscMessage oscStartSettings = new OscMessage("/test");
  oscStartSettings.add(546);
  oscP5.send(oscStartSettings,superCollider);

}



void oscEvent(OscMessage theOscMessage){

  //theOscMessage.print();
  
  if(theOscMessage.addrPattern().equals("/mouse")){
    x=theOscMessage.get(0).floatValue();
    y=theOscMessage.get(1).floatValue();
    
    
    
    //print(" addrpattern: "+theOscMessage.addrPattern());
    //print("0: "+theOscMessage.get(0).floatValue());
    //print("1: "+theOscMessage.get(1).floatValue());
    
  }
}


///* incoming osc message are forwarded to the oscEvent method. */
//void oscEvent(OscMessage theOscMessage) {
//  /* print the address pattern and the typetag of the received OscMessage */
//  print("### received an osc message.");
//  print(" addrpattern: "+theOscMessage.addrPattern());
//  println(" typetag: "+theOscMessage.typetag());
//  theOscMessage.print();
//}
