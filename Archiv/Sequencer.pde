import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress superCollider;
NetAddress oscJunction;


int num_XBlocks = 8;
int num_YBlocks = 4;
int delayTime = 500;
boolean showRegion = true;


int posX=0;
int posY=0;
int XBlockSize, YBlockSize;
color[] backgroundImage;

ArrayList<PShape> shapes = new ArrayList<PShape>();  //Liste um hizugefügte PShapes zu speichern, zum späteren verändern und zum drawen der Shapes
//Vorteil von ArrayList gegenüber Array ist dass man easy neue Elemente hinzufügen oder entfernen kann
//PShape ist eine Klasse mit der man gut shapes erstellen oder theoretisch aus mehreren Shapes einen Shape zusammenstellen kann, hat auch paar nützliche Funktionen zum Drehen, Bewegen oder Skalieren


void settings() {
  oscP5 = new OscP5(this, 12000);
  superCollider = new NetAddress("127.0.0.1", 57120);
  oscJunction = new NetAddress("127.0.0.1", 57140);
  size(800, 400);
}

void setup() {

  XBlockSize = width/num_XBlocks;
  YBlockSize = height/num_YBlocks;

  loadPixels();
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      int loc = x + y * width;
      pixels[loc] = color(x/6, y/2, x/4);
    }
  }

  backgroundImage = new color[width*height];
  arrayCopy(pixels, backgroundImage);
}

void draw() {

  //background(0, 0, 0); // macht alles schwarz, damit das folgene darüber gezeichnet werden kann -> Hintergrund

  loadPixels();  
  arrayCopy(backgroundImage, pixels);
  updatePixels();

  //iteriert durch alle PShapes in unserer Liste und zeichnet sie
  for (int i = 0; i<shapes.size(); i++) {
    shape(shapes.get(i));
  }

  //####################### Abgreifen der Farb-Werte #####################





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

  //prüft ob der OSC.Path dem Befehl(/new_shape) gleicht
  if (theOscMessage.addrPattern().equals("/new_shape")) {

    PShape shape;
    if (theOscMessage.get(0).stringValue().equals("ELLIPSE")) {

      //erstellt neue Shape mit den Parametern der OSC-Nachricht
      shape  = createShape(ELLIPSE, theOscMessage.get(1).floatValue(), theOscMessage.get(2).floatValue(), theOscMessage.get(3).floatValue(), theOscMessage.get(4).floatValue());
      shapes.add(shape);// fügt neue Shape unserer Liste hinzu
      
    } else if (theOscMessage.get(0).stringValue().equals("RECT")) {
      shape = createShape(RECT, theOscMessage.get(1).floatValue(), theOscMessage.get(2).floatValue(), theOscMessage.get(3).floatValue(), theOscMessage.get(4).floatValue());
      shapes.add(shape);
      
    } else
      print("Error (1337): shapeType not found");
      
      
  } else if (theOscMessage.addrPattern().equals("/color_shape")) {

    PShape shape = shapes.get(theOscMessage.get(0).intValue());

    //setzt die FüllFarbe der Shape 
    shape.setFill(color(theOscMessage.get(1).intValue(), theOscMessage.get(2).intValue(), theOscMessage.get(3).intValue()));
    
  } else if (theOscMessage.addrPattern().equals("/move_shape")) {

    PShape shape = shapes.get(theOscMessage.get(0).intValue());
    shape.translate(theOscMessage.get(1).intValue(), theOscMessage.get(2).intValue());
    
  } else
    print("Error (69): Command not found");
}
