//SUPERCOLLIDER BEISPIELCODE GANZ UNTEN

import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress superCollider;


ArrayList<PShape> shapes = new ArrayList<PShape>();  //Liste um hizugefügte PShapes zu speichern, zum späteren verändern und zum drawen der Shapes
//Vorteil von ArrayList gegenüber Array ist dass man easy neue Elemente hinzufügen oder entfernen kann
//PShape ist eine Klasse mit der man gut shapes erstellen oder theretisch aus aus mehreren Shapes eine Shape zusammenstellen kann, hat auch paar nützliche Funktionen zum Drehen, Bewegen oder Skalieren

void settings() {
  oscP5 = new OscP5(this, 12000);
  superCollider = new NetAddress("127.0.0.1", 57120);

  size(800, 800);
}


void draw(){
  
  background(0,0,0); // macht alles schwarz, damit das folgene darüber gezeichnet werden kann -> Hintergrund
  
  
  //iteriert durch alle PShapes in unserer Liste und zeichnet sie
  for( PShape shape : shapes){
    shape(shape);
  }

}


//Hier kommen Alle OSC-Nachrichten an
void oscEvent(OscMessage theOscMessage){

  theOscMessage.print(); // gibt die OscMessage aus, mit datenTypen und jedem einzelnem Wert. gut zum Debuggen
  
  //prüft ob der OSC.Path dem Befehl(/new_shape) gleicht
  if(theOscMessage.addrPattern().equals("/new_shape")){
    
    PShape shape;
    //
    if(theOscMessage.get(0).stringValue().equals("ELLIPSE")){
      
      //erstellt neue Shape mit den Parametern der OSC-Nachricht
      shape  = createShape(ELLIPSE,theOscMessage.get(1).floatValue(),theOscMessage.get(2).floatValue(),theOscMessage.get(3).floatValue(),theOscMessage.get(4).floatValue());
      
      shapes.add(shape);// fügt neue Shape unserer Liste hinzu
    
      
    }else if(theOscMessage.get(0).stringValue().equals("RECT")){
      shape = createShape(RECT,theOscMessage.get(1).floatValue(),theOscMessage.get(2).floatValue(),theOscMessage.get(3).floatValue(),theOscMessage.get(4).floatValue());
      shapes.add(shape);
    }else
      print("Error (1337): shapeType not found");

   
   
   
  }else if(theOscMessage.addrPattern().equals("/color_shape")){
  
    PShape shape = shapes.get(theOscMessage.get(0).intValue());
    
    //setzt die FüllFarbe der Shape 
    shape.setFill(color(theOscMessage.get(1).intValue(),theOscMessage.get(2).intValue(),theOscMessage.get(3).intValue()));
  
  
  
  
  
  }else if(theOscMessage.addrPattern().equals("/move_shape")){
  
    PShape shape = shapes.get(theOscMessage.get(0).intValue());
    
    shape.translate(theOscMessage.get(1).intValue(),theOscMessage.get(2).intValue());
  
  }else
    print("Error (69): Command not found");
}




/*
###########################################SUPERCOLLIDER-CODE#################################################

p = NetAddr("127.0.0.1", 12000); // Processing-Port


//neue Figuren erstellen:
p.sendMsg("/new_shape","ELLIPSE",200.0,200.0,100.0,100.0); 
//[posX, posY, heigth, width] | ALLE ALS FLOAT, sonst error

p.sendMsg("/new_shape","RECT",300.0,300.0,400.0,400.0); 
//[posX, posY, heigth, width] | pos is upperleft corner  | ALLE ALS FLOAT, sonst error


//Farbe ändern
p.sendMsg("/color_shape",0,255,0,150);
//[ID,red,green,blue] |ALLE ALS INTEGER, sonst error | ID zählt von 0 hoch und wird beim Erstellen(/new_shape) zugewiesen

//bewegen
p.sendMsg("/move_shape",0, 20, 10);
// [ID,x,y] | ALLE ALS INTEGER, sonst error | moves the shape x in X-Direction and y in Y-Direction. negatives allowed




*/
