
import codeanticode.syphon.*;
import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress superCollider;
NetAddress oscJunction;

SyphonServer server;

int num_XBlocks = 8;
int num_YBlocks = 4;
boolean showRegion = true;




int posX=2;
int posY=1;
int XBlockSize, YBlockSize;
color[] image;

ArrayList<PGraphics> pgs = new ArrayList<PGraphics>();
ArrayList<Float> blendModes = new ArrayList<Float>();

void settings() {
  oscP5 = new OscP5(this, 12000);
  superCollider = new NetAddress("127.0.0.1", 57120);
  oscJunction = new NetAddress("127.0.0.1", 57140);
  
  size(800, 400,P3D);
  //textureMode(NORMAL);
  

  

}

void setup() {

  XBlockSize = width/num_XBlocks;
  YBlockSize = height/num_YBlocks;
  
  server = new SyphonServer(this, "Processing Syphon");
  
  noStroke();

  loadPixels();
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      int loc = x + y * width;
      pixels[loc] = color(x/6, y/2, x/4);
    }
  }

  image = new color[width*height];
  arrayCopy(pixels, image);
  
  
  
}

void draw() {
  
  server.sendScreen();


  loadPixels();  
  arrayCopy(image, pixels);
  updatePixels();
  
  
  
  //############## Draw Shapes from Queue #############################
  imageMode(CORNER);
  for(int i=0;i<pgs.size();i++){
    
    if(blendModes.get(i)==0){
      blendMode(BLEND);
      image(pgs.get(i),0,0);
    }else{
      pgs.get(i).loadPixels();
      loadPixels();
      color c;
      float r,g,b,a;
      for (int x=0; x<width; x++) {
        for (int y=0; y<height; y++) {
          c = pgs.get(i).pixels[x+y*width];
          if (alpha(c)!=0) {
            
            a=alpha(c);
            
            c = pixels[x+y*width];
            r= red(c);
            g= green(c);
            b= blue(c);

            //println("r: ",r , "g: ", g,  "b: ", b,  "a: ", a);
            if(a==255){
              c= color(255-r,255-g,255-b);
            }else{
              c = lerpColor(c,color(255-r,255-g,255-b),a/255);
            }
  
            pixels[x+y*width]=c;
          }
        }
      }
      updatePixels();
    }
  }
  
  pgs.clear();
  blendModes.clear();
  
  loadPixels();
  arrayCopy(pixels, image);
  //updatePixels();





  //####################### Abgreifen der Farb-Werte #####################

  int delayTime = 250;

  int time = millis()%(num_YBlocks*num_XBlocks*delayTime);
  int minTime = posX*delayTime+posY*num_XBlocks*delayTime;
  int maxTime = posX*delayTime+posY*num_XBlocks*delayTime +delayTime;

  //print(time,minTime,maxTime,"\n");
  if ((time>minTime) && (time <maxTime)) {

    float sum_r=0, sum_g=0, sum_b = 0, sum_br=0, sum_hue=0, sum_sat=0;
    int offset = XBlockSize*posX + (YBlockSize)*width*posY;
    loadPixels();
    for (int y = 0; y<YBlockSize; y++) {
      for (int x = 0; x <XBlockSize; x++) {
      
        int loc = x + y * width + offset;

        //insert stuff here
        //pixels[loc] = color(255,0,0);

        color c = pixels[loc];
        float br, hue, sat, r, g, b;

        br = brightness(c);
        hue = hue(c);
        sat = saturation(c);

        r = red(c);
        g = green(c);
        b = blue(c);

        sum_br = sum_br + br;
        sum_hue = sum_hue + hue;
        sum_sat = sum_sat + sat;

        sum_r = sum_r + r;
        sum_g = sum_g + g;
        sum_b = sum_b + b;
      }
    }
    
    posX++;
    if (posX>=num_XBlocks) {
      posY++;
      posX=0;
    }
    if (posY>=num_YBlocks) {
      posY=0;
    }

    int numPixels = YBlockSize*XBlockSize;
    
    float avg_r = sum_r/(numPixels);
    float avg_g = sum_g/(numPixels);
    float avg_b = sum_b/(numPixels);

    float avg_br = sum_br/(numPixels);
    float avg_hue = sum_hue/(numPixels);
    float avg_sat = sum_sat/(numPixels);
    
    sendOscMsg("/rgb", avg_r, avg_g, avg_b);
    sendOscMsg("/hsv", avg_hue, avg_sat, avg_br);
  }


//############### momentaner Block Anzeige ###############

  if (showRegion) {
   
    loadPixels();
    color c;
    int lastPosX = posX;
    int lastPosY = posY;

    if(--lastPosX<0){
      lastPosX=num_XBlocks-1;

      if(--lastPosY<0){
        lastPosY = num_YBlocks-1;
      }
    }
    //print("X: ",posX,lastPosX,"\n");
    //print("Y:",posY,lastPosY,"\n");
    
    for (int y =lastPosY*YBlockSize; y<lastPosY*YBlockSize+YBlockSize; y=y+YBlockSize-1) {
      for (int x=lastPosX*XBlockSize; x<lastPosX*XBlockSize+XBlockSize; x++) {

        int loc = x + y * width;
        c = pixels[loc];
        pixels[loc] = color(255-red(c), 255-green(c), 255-blue(c));
      }
    }


    for (int x =lastPosX*XBlockSize; x<lastPosX*XBlockSize+XBlockSize; x=x+XBlockSize-1 ) {
      for (int y=lastPosY*YBlockSize+1; y<lastPosY*YBlockSize-1+YBlockSize; y++) {

        int loc = x + y * width;
        c = pixels[loc];
        pixels[loc] = color(255-red(c), 255-green(c), 255-blue(c));
      }
    }

    updatePixels();
  }
  
  
  
}




void sendOscMsg(String path, float ... values) {

  OscMessage oscStartSettings = new OscMessage(path);  
  for (float value : values) {
    oscStartSettings.add(value);
  }
  oscP5.send(oscStartSettings, superCollider);
}








//Hier kommen Alle OSC-Nachrichten an
void oscEvent(OscMessage theOscMessage) {

  theOscMessage.print(); // gibt die OscMessage aus, mit datenTypen und jedem einzelnem Wert. gut zum Debuggen
  
  if (theOscMessage.addrPattern().equals("/poly")) {
    // "/poly", rotation, farbMode, r, g, b, point1X, point1Y, point2X, point2Y, ...
   
    float rotation = theOscMessage.get(0).floatValue();
    float blendMode = theOscMessage.get(1).floatValue();
    float r = theOscMessage.get(2).floatValue();
    float g = theOscMessage.get(3).floatValue();
    float b = theOscMessage.get(4).floatValue();
    
    Float[] points =new Float[theOscMessage.arguments().length-5];
    arrayCopy(theOscMessage.arguments(),5,points,0,theOscMessage.arguments().length-5);
    
    float bottom = -1, right = -1;
    float top = height+1;
    float left = width+1;
    
    for(int i = 0;i<points.length;i+=2){
      //println(points[i]," ", points[i+1]);
      if(points[i]<left)
        left = points[i];
        
      if(points[i]>right)
        right = points[i];
        
      if(points[i+1]<top)
        top = points[i+1];
        
      if(points[i+1]>bottom)
        bottom = points[i+1];  
    }
    
    float centerPointX = left+(right-left)/2;
    float centerPointY = top+(bottom-top)/2;
    
    
    PGraphics pg = createGraphics(width,height);

      pg.beginDraw();    
      pg.pushMatrix();
      
      if(blendMode==0)
        pg.fill(r,g,b);
      else
        pg.fill(255,255);
      pg.noStroke();
      pg.translate(centerPointX,centerPointY);
      pg.rotate(rotation);

      pg.beginShape();
      for(int i = 0;i<points.length;i+=2){
        pg.vertex(points[i]-centerPointX,points[i+1]-centerPointY);
      }
      pg.endShape();
      
      pg.popMatrix();
      pg.endDraw();
       
      pgs.add(pg);   
      blendModes.add(blendMode);
      
  }else{
    
    // "/ellipse", point1X, point1Y, point2X, point2Y, rotation, farbMode, r, g, b
    // "/rect",    point1X, point1Y, point2X, point2Y, rotation, farbMode, r, g, b
    // "/triangle",point1X, point1Y, point2X, point2Y, rotation, farbMode, r, g, b
      
      float originPosX =theOscMessage.get(0).floatValue();
      float originPosY =theOscMessage.get(1).floatValue();
      float secondPosX = theOscMessage.get(2).floatValue();
      float secondPosY = theOscMessage.get(3).floatValue();
      float rotation = theOscMessage.get(4).floatValue();
      float blendMode = theOscMessage.get(5).floatValue();
      float r = theOscMessage.get(6).floatValue();
      float g = theOscMessage.get(7).floatValue();
      float b = theOscMessage.get(8).floatValue();
      
      float centerPointX = originPosX+(secondPosX-originPosX)/2;
      float centerPointY = originPosY+(secondPosY-originPosY)/2;
      
      PGraphics pg = createGraphics(width,height);
      
      pg.beginDraw();    
      pg.pushMatrix();
      
      if(blendMode==0)
        pg.fill(r,g,b);
      else
        pg.fill(255,255);
      pg.noStroke();
      
      pg.translate(centerPointX,centerPointY);
      pg.rotate(rotation);

      if (theOscMessage.addrPattern().equals("/rect")) {
        pg.rectMode(CENTER);
        pg.rect(0,0,secondPosX-originPosX,secondPosY-originPosY);
      }
      else if (theOscMessage.addrPattern().equals("/ellipse")){
        pg.ellipseMode(CENTER);
        pg.ellipse(0,0,secondPosX-originPosX,secondPosY-originPosY);
      }else if (theOscMessage.addrPattern().equals("/triangle")){
        println("triangle happend");
        pg.triangle(originPosX-centerPointX, secondPosY-centerPointY, (originPosX+secondPosX)/2-centerPointX, originPosY-centerPointY, secondPosX-centerPointX, secondPosY-centerPointY);
      
      }
      pg.popMatrix();
      pg.endDraw();
       
      pgs.add(pg);   
      blendModes.add(blendMode);
      
  }



}




void keyPressed() {
  if (key == 's' || key == 'S') {
    String webColor = "#ED225D";
    color col = unhex( "FF"  +webColor.substring(1,6));
    println(col);
    println(red(col),green(col),blue(col));      
      
    fill(col);
    rect(300,300,500,500);
    
  }else if(key == 't' || key == 'T') {
    
    PGraphics pg = createGraphics(width,height);
    

    pg.beginDraw();    
    pg.pushMatrix();
    pg.fill(255);
    pg.noStroke();
    pg.translate(275,275);
    pg.rotate(1.0*mouseX/width*2*PI);
        
    pg.rect(0,0,150,150);
    pg.popMatrix();
    pg.endDraw();

    
    pgs.add(pg);
    
    blendModes.add(1.0);
    
    print("t pressed");
      
  }else if (key == 'r' || key == 'R') {
    //RESET
    
    loadPixels();
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        int loc = x + y * width;
        pixels[loc] = color(x/6, y/2, x/4);
      }
    }
  
    image = new color[width*height];
    arrayCopy(pixels, image);
    
    pgs.clear();
    blendModes.clear();
  
    posX=2;
    posY=1;
  
  }
}
/*TODO
Stroke oder noStroke ?
*/
