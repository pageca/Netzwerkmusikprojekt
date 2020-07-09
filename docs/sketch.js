let originPosX;
let originPosY;
let secondPosX;
let secondPosY;

let rotation = 0;

let polyVertexes = [];

let debugText = ['hi'];
let mouseInCanvas;

let node;
let junction;

let lastMouseX;
let lastMouseY;
let mouseWasDragged;

let missTexture;
let tempTexture;
let shape;

let scale = 2;


function connectJunctionSuccess(connectedJunction) {
	junction = connectedJunction;
	print("Connected to Junction!");
}

function connectNodeSuccess(connectedNode) {
	node = connectedNode;
	node.connectJunctionSend("WebTest", "1111", connectJunctionSuccess);
}

function fail(errorMessage) {
	print(errorMessage);
}

function preload(){

  missTexture = loadImage('data/missTexture.jpg');

}

function setup() {
  let canvas = createCanvas(640, 360);
  canvas.parent(document.getElementById('canvasDiv'));

  OSCjunction.connect("node-1", connectNodeSuccess, fail);

  ellipseMode(CORNERS);
  rectMode(CORNERS);

  shapeType = createRadio();
  shapeType.option('ellipse');
  shapeType.option('rectangle');
  shapeType.option('triangle');
  shapeType.option('polygon');
  shapeType.value('rectangle');
  shapeType.parent(document.getElementById('shapeType'));
  shapeType.changed(uiChanged);

  drawMode = createRadio();
  drawMode.option('draw',1);
  drawMode.option('rotate',2);
  drawMode.value('1');
  drawMode.parent(document.getElementById('drawMode'));
  drawMode.changed(uiChanged);
 

  farbMode = createCheckbox('invert Colors', false);
  farbMode.parent(document.getElementById('farbMode'));
  farbMode.changed(uiChanged);

  colorPicker = createColorPicker('#ed225d');
  colorPicker.parent(document.getElementById('colorPicker'));
  colorPicker.changed(uiChanged);

  sendButton = createButton('Send');
  sendButton.parent(document.getElementById('sendButton'));
  sendButton.size(110,40);
  sendButton.mousePressed(sendOut);
  sendButton.style('background-color', color(18, 161, 87));
  sendButton.style('color', color(186, 247, 216));  
  sendButton.style('font-size','20px');


  resetButton = createButton('Reset');
  resetButton.parent(document.getElementById('resetButton'));
  resetButton.size(55,20);
  resetButton.mousePressed(reset);
  resetButton.style('background-color', color(171, 48, 48));
  resetButton.style('color', color(250, 220, 220));  

  tempTexture = createImage(width,height);
  shape = createGraphics(width,height);
  
  missTexture.loadPixels();

  noLoop();
}



function draw() {
  background(208, 218, 255);

  fill(colorPicker.color());

  maxSize = 80;

  debugText ="";
  
  if (mouseInCanvas && (drawMode.value() == 1)) {
    //debugText = debugText + "drawMode: 1 ";
    if (mouseX > originPosX + maxSize) {
      secondPosX = originPosX + maxSize;
    } else if (mouseX < originPosX - maxSize) {
      secondPosX = originPosX - maxSize;
    } else {
      secondPosX = mouseX;
    }

    if (mouseY > originPosY + maxSize) {
      secondPosY = originPosY + maxSize;
    } else if (mouseY < originPosY - maxSize) {
      secondPosY = originPosY - maxSize;
    } else {
      secondPosY = mouseY;
    }
  }


  push();
  
  if(shapeType.value() == "polygon") {
      
    let top = height+1;
    let bottom = -1;
    let left = width+1;
    let right = -1;
    for(let i=0;i < polyVertexes.length; i++) {
      if(polyVertexes[i][0]<left){
        left = polyVertexes[i][0];
      }
      if(polyVertexes[i][0]>right){
        right = polyVertexes[i][0];
      }
      if(polyVertexes[i][1]<top){
        top = polyVertexes[i][1];
      }
      if(polyVertexes[i][1]>bottom){
        bottom = polyVertexes[i][1];
      }
    }
    
    let centerPointX = left+(right-left)/2;
    let centerPointY = top+(bottom-top)/2;
  
    if( (drawMode.value() == 2) && mouseWasDragged){    
      debugText = debugText + "drawMode: 2 ";
      rotation = rotation + (atan2(mouseY-centerPointY,mouseX-centerPointX) - atan2(lastMouseY-centerPointY,lastMouseX-centerPointX));
      lastMouseX = mouseX;
      lastMouseY = mouseY;
    }

    if(farbMode.checked()){
      shape = createGraphics(width,height);
      shape.fill(0);
      shape.ellipseMode(CORNERS);
      shape.rectMode(CORNERS);
      
      tempTexture.copy(missTexture, 0, 0, width, height, 0, 0, width, height);

      shape.translate(centerPointX,centerPointY);
      shape.rotate(rotation);


      
      shape.beginShape();

      for (let i = 0; i < polyVertexes.length; i++) {
        shape.vertex(polyVertexes[i][0]-centerPointX, polyVertexes[i][1]-centerPointY);
      }
      shape.endShape();

      if(polyVertexes.length>1){
        shape.line(polyVertexes[0][0]-centerPointX, polyVertexes[0][1]-centerPointY, polyVertexes[polyVertexes.length-1][0]-centerPointX, polyVertexes[polyVertexes.length-1][1]-centerPointY);
      }

      tempTexture.mask(shape);
      image(tempTexture,0,0);

    }else{    

      translate(centerPointX,centerPointY);
      rotate(rotation);
      
      beginShape();

      for (let i = 0; i < polyVertexes.length; i++) {
        vertex(polyVertexes[i][0]-centerPointX, polyVertexes[i][1]-centerPointY);
      }
      endShape();

      if(polyVertexes.length>1){
        line(polyVertexes[0][0]-centerPointX, polyVertexes[0][1]-centerPointY, polyVertexes[polyVertexes.length-1][0]-centerPointX, polyVertexes[polyVertexes.length-1][1]-centerPointY);
      }
    }

  }else{

    let centerPointX = originPosX+(secondPosX-originPosX)/2;
    let centerPointY = originPosY+(secondPosY-originPosY)/2;
    if(mouseWasDragged && (drawMode.value() == 2)){    
      rotation = rotation + (atan2(mouseY-centerPointY,mouseX-centerPointX) - atan2(lastMouseY-centerPointY,lastMouseX-centerPointX));
      lastMouseX = mouseX;
      lastMouseY = mouseY;
    }

    if(farbMode.checked()){

      shape = createGraphics(width,height);
      shape.fill(0);
      shape.ellipseMode(CORNERS);
      shape.rectMode(CORNERS);
      
      tempTexture.copy(missTexture, 0, 0, width, height, 0, 0, width, height);

      shape.translate(centerPointX,centerPointY);
      shape.rotate(rotation);

      if(shapeType.value() == "ellipse") {
              
        shape.ellipseMode(CENTER); 
        shape.ellipse(0,0,secondPosX-originPosX,secondPosY-originPosY);
        
      }else if(shapeType.value() == "rectangle") {
          
        shape.rectMode(CENTER); 
        shape.rect(0,0,secondPosX-originPosX,secondPosY-originPosY);
        
      }else if(shapeType.value() == "triangle"){
        shape.triangle(originPosX-centerPointX, secondPosY-centerPointY, (originPosX+secondPosX)/2-centerPointX, originPosY-centerPointY, secondPosX-centerPointX, secondPosY-centerPointY);

      }

      tempTexture.mask(shape);
      image(tempTexture,0,0);

    }else{

      translate(centerPointX,centerPointY);
      rotate(rotation);

      if(shapeType.value() == "ellipse") {
              
        ellipseMode(CENTER); 
        ellipse(0,0,secondPosX-originPosX,secondPosY-originPosY);
        
      }else if(shapeType.value() == "rectangle") {
          
        rectMode(CENTER); 
        rect(0,0,secondPosX-originPosX,secondPosY-originPosY);
        
      }else if(shapeType.value() == "triangle"){
        triangle(originPosX-centerPointX, secondPosY-centerPointY, (originPosX+secondPosX)/2-centerPointX, originPosY-centerPointY, secondPosX-centerPointX, secondPosY-centerPointY);

      }
    }
  }

  pop();

  //text(debugText,100,50);

}


function mousePressed() {
  if((mouseX > 0) && (mouseX < width )&& (mouseY > 0) && (mouseY < height)){
    mouseInCanvas = true;
  }else
    mouseInCanvas = false;

  if  (mouseInCanvas){
    if (shapeType.value() == "polygon" && drawMode.value() == 1) {
      rotation = 0;
      polyVertexes.push([mouseX, mouseY]);

    } else if(drawMode.value() == 1) {
    
      originPosX = mouseX;
      originPosY = mouseY;
      rotation = 0;
      print("mouse is pressed");
    
    } else if(drawMode.value() == 2){
            
      lastMouseX = mouseX;
      lastMouseY = mouseY;
    
    }

    if(drawMode.value() ==2)
      cursor('GRABBING');
    else if(shapeType.value() == 'polygon')
      cursor(CROSS);
    else
      cursor('none');

    redraw();
  }

  //debugText = [mouseX,mouseY,'  ', width,height];

}

function mouseDragged() {
  if  (mouseInCanvas){
    mouseWasDragged = true;
    redraw();
  }
}


function mouseReleased(){

  if(drawMode.value() ==2)
    cursor('GRAB');
  else if(shapeType.value() == 'polygon')
    cursor(CROSS);
  else
    cursor(ARROW);

  mouseWasDragged = false;
}



function sendOut(){

  let invertMode;

  if(farbMode.checked())
    invertMode=1;
  else
    invertMode=0;

  if(junction !== undefined && junction.connected) {

    
    if(shapeType.value()=='rectangle')
      junction.send("/rect", [originPosX*scale,originPosY*scale,secondPosX*scale,secondPosY*scale,rotation,invertMode,red(colorPicker.value()),green(colorPicker.value()),blue(colorPicker.value())]);
    else if(shapeType.value()=='ellipse')
      junction.send("/ellipse", [originPosX*scale,originPosY*scale,secondPosX*scale,secondPosY*scale,rotation,invertMode,red(colorPicker.value()),green(colorPicker.value()),blue(colorPicker.value())]);
    else if(shapeType.value()=='triangle')
      junction.send("/triangle", [originPosX*scale,originPosY*scale,secondPosX*scale,secondPosY*scale,rotation,invertMode,red(colorPicker.value()),green(colorPicker.value()),blue(colorPicker.value())]);
    else {
      let args =[rotation,invertMode,red(colorPicker.value()),green(colorPicker.value()),blue(colorPicker.value())];
      
      for (let i = 0; i < polyVertexes.length; i++) {
        args.push(polyVertexes[i][0] * scale);
        args.push(polyVertexes[i][1] * scale);
      }
      junction.send("/poly",args);

    }
  }

  //debugText = [originPosX,originPosY,secondPosX,secondPosY,rotation,invertMode,red(colorPicker.value()),green(colorPicker.value()),blue(colorPicker.value())];
  //debugText = [originPosX*scale,originPosY*scale,secondPosX*scale,secondPosY*scale,rotation,invertMode];
  reset();

}

function keyPressed(){
  if (keyCode === ENTER) {
		sendOut();
  }
}

function reset(){

  polyVertexes = [];
  rotation=0;
  originPosX = -1;
  originPosY = -1;
  secondPosX = -1;
  secondPosY = -1;  
  mouseInCanvas = false;
  redraw();


}

function uiChanged(){
  mouseInCanvas = false;

  if(drawMode.value() ==2)
    cursor('GRAB');
  else if(shapeType.value() == 'polygon')
    cursor(CROSS);
  else
    cursor(ARROW);

  redraw();
}



/*ToDo

-Style


*/
