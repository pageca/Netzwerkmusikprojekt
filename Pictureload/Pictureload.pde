//Picture
//sachen die man einfügen kann: rect(), elipse(), line(), bubble()
//argumente: (x,y,width,height)
PImage img;

void setup() {
  size(1900,800);
 img = loadImage("test.jpg");
   background(0);

}

void draw() {
  //tint gibt bilder nen neuen farbstich (r,g,b)
 // tint(255,mouseX,mouseY);
 // image(img,0,0);
  
 //sachen ins bild einfügen: ps: fill gibt formen ne farbe
 //fill(0,255,0);
 //ellipse(300,200,10,10);
  
 //set() Kann man den Farbwert einzelner Pixel verändern
 //hier jetzt durch forschleife nen strich gemalt
// for (int x=0; x<width; x++) {
//  set(x,200,color(250,0,0));
// }
 //Eigene Hintergründe gestallten:
 
 //pixels() speichert alle pixels in einer variable bzw in einem langen array
// loadPixels(); //muss man immer vorher schreiben bevor man pixels benutzt
// for (int i = 0; i < pixels.length; i++){
//  pixels[i] = color(random(mouseY),0,random(50,mouseX)); 
 //}
// updatePixels(); //muss man immer am ende schreiben


//Auf alle Pixels zugreifen: So kann man verschiedene Regionen des Bildes einfärben

// loadPixels(); 
 //for (int x = 0; x < width; x++){
 //   for (int y = 0; y < height; y++){
  //    int loc = x + y * width;
  // pixels[loc] = color(x/6,y/2,x*1/4); 
//   } 
 //}
 updatePixels(); 

//FRAGE: Wie erstellt man alpha channel, dass es durchsichtig wird und man immer noch bild sieht?


 //loadPixels(); 
 //img.loadPixels();
 //for (int x = 0; x < width; x++){
  //  for (int y = 0; y < height; y++){
  //    int loc = x + y * width;
 // pixels[loc] = color(x/6,y/2,x*1/4); 
 //pixels[loc] = img.pixels[loc]; 
 //  } 
 //}
// updatePixels(); 


//selber Malen:
float c = random(width);
float e = random(height);

fill(random(255,25),0,random(255));
ellipse(c,e,90,90);
}
