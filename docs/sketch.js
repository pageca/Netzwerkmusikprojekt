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

//test

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


function setup() {
  let canvas = createCanvas(800, 400);
  canvas.position(90,540);

  OSCjunction.connect("node-1", connectNodeSuccess, fail);

  ellipseMode(CORNERS);
  rectMode(CORNERS);

  shapeType = createRadio();
  shapeType.option('ellipse');
  shapeType.option('rectangle');
  shapeType.option('triangle');
  shapeType.option('polygon');
  shapeType.value('rectangle');
  shapeType.position(900,600)
  shapeType.changed(uiChanged);

  drawMode = createRadio();
  drawMode.option('draw',1);
  drawMode.option('rotate',2);
  drawMode.value('1');
  drawMode.position(900,700);
  drawMode.changed(uiChanged);
 

  farbMode = createCheckbox('invert Colors', false);
  farbMode.position(950,545);
  farbMode.changed(uiChanged);

  colorPicker = createColorPicker('#ed225d');
  colorPicker.position(900,545);
  colorPicker.changed(uiChanged);

  sendButton = createButton('Send');
  sendButton.position(900,800);
  sendButton.mousePressed(sendOut);

  resetButton = createButton('Reset');
  resetButton.position(980,800);
  resetButton.mousePressed(reset);

  tempTexture = createImage(width,height);
  missTexture = createImage(width,height);
  shape = createGraphics(width,height);
  
  missTexture.loadPixels();
  let rastersize = 10;
  let pinkOrBlack
  for (let x = 0; x < width - rastersize; x = x + rastersize) {
    for (let y = 0; y < width - rastersize; y = y + rastersize) {
      
      pinkOrBlack = !pinkOrBlack;
      for (let ix = 0; ix <rastersize; ix++) {
        for (let iy = 0; iy <rastersize; iy++) {
          
          let c;
          if(pinkOrBlack)
            c= color(0);
          else
            c=color(235,0,235);
          missTexture.pixels[(x+ix+(y+iy)*width)*4]=red(c);
          missTexture.pixels[(x+ix+(y+iy)*width)*4+1]=0;
          missTexture.pixels[(x+ix+(y+iy)*width)*4+2]=blue(c);
          missTexture.pixels[(x+ix+(y+iy)*width)*4+3]=255;
        }
      }

    }
  }
  
  missTexture.updatePixels();



  noLoop();
}



function draw() {
  background(220);


  fill(colorPicker.color());
  print(red(colorPicker.value()),green(colorPicker.value()),blue(colorPicker.value()));

  maxSize = 100;

  text(debugText,100,50);

  //Draw
  if (drawMode.value() == 1) {

    //print("lol",drawMode.value());

    if (mouseInCanvas) {
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

    if(farbMode.checked()){
      shape = createGraphics(width,height);
      shape.fill(0);
      shape.ellipseMode(CORNERS);
      shape.rectMode(CORNERS);

      tempTexture.copy(missTexture, 0, 0, width, height, 0, 0, width, height);

      if (shapeType.value() == "ellipse") {
        shape.ellipse(originPosX, originPosY, secondPosX, secondPosY);
      } else if (shapeType.value() == "rectangle") {
        shape.rect(originPosX, originPosY, secondPosX, secondPosY);
      } else if (shapeType.value() == "triangle"){
        shape.triangle(originPosX, secondPosY, (originPosX+secondPosX)/2, originPosY, secondPosX, secondPosY);
      } else if (shapeType.value() == "polygon") {


        shape.beginShape();

        for (let i = 0; i < polyVertexes.length; i++) {
          shape.vertex(polyVertexes[i][0], polyVertexes[i][1]);
        }
        shape.endShape();
        if(polyVertexes.length>1){
          shape.line(polyVertexes[0][0], polyVertexes[0][1], polyVertexes[polyVertexes.length-1][0], polyVertexes[polyVertexes.length-1][1]);
        }

      }

      tempTexture.mask(shape);
      image(tempTexture,0,0);

    }else{
      if (shapeType.value() == "ellipse") {
        ellipse(originPosX, originPosY, secondPosX, secondPosY);
      } else if (shapeType.value() == "rectangle") {
        rect(originPosX, originPosY, secondPosX, secondPosY);
      } else if (shapeType.value() == "triangle"){
        triangle(originPosX, secondPosY, (originPosX+secondPosX)/2, originPosY, secondPosX, secondPosY);
      } else if (shapeType.value() == "polygon") {


        beginShape();

        for (let i = 0; i < polyVertexes.length; i++) {
          vertex(polyVertexes[i][0], polyVertexes[i][1]);
        }
        endShape();
        if(polyVertexes.length>1){
          line(polyVertexes[0][0], polyVertexes[0][1], polyVertexes[polyVertexes.length-1][0], polyVertexes[polyVertexes.length-1][1]);
        }

      }
    }

  //Rotation  
  } else if (drawMode.value() == 2) {
    
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
    
      if(mouseWasDragged){    
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
      if(mouseWasDragged){    
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

  }

}


function mousePressed() {
  if((mouseX > 0) && (mouseX < width )&& (mouseY > 0) && (mouseY < height)){
    mouseInCanvas = true;
  }else
    mouseInCanvas = false;

  if  (mouseInCanvas){
    if (shapeType.value() == "polygon" && drawMode.value() == 1) {
      polyVertexes.push([mouseX, mouseY]);

    } else if(drawMode.value() == 1) {
    
      originPosX = mouseX;
      originPosY = mouseY;
      rotation = 0;
      print("mouse is pressed");
    
    } else if(drawMode.value() == 2){
            
      //rotation = 0;
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
  //redraw();

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
      junction.send("/rect", [originPosX,originPosY,secondPosX,secondPosY,rotation,invertMode,red(colorPicker.value()),green(colorPicker.value()),blue(colorPicker.value())]);
    else if(shapeType.value()=='ellipse')
      junction.send("/ellipse", [originPosX,originPosY,secondPosX,secondPosY,rotation,invertMode,red(colorPicker.value()),green(colorPicker.value()),blue(colorPicker.value())]);
    else if(shapeType.value()=='triangle')
      junction.send("/triangle", [originPosX,originPosY,secondPosX,secondPosY,rotation,invertMode,red(colorPicker.value()),green(colorPicker.value()),blue(colorPicker.value())]);
    else {
      let args =[rotation,invertMode,red(colorPicker.value()),green(colorPicker.value()),blue(colorPicker.value())];
      
      for (let i = 0; i < polyVertexes.length; i++) {
        args.push(polyVertexes[i][0]);
        args.push(polyVertexes[i][1]);
      }
      junction.send("/poly",args);

    }
  }

  //debugText = [originPosX,originPosY,secondPosX,secondPosY,rotation,invertMode,red(colorPicker.value()),green(colorPicker.value()),blue(colorPicker.value())];
  debugText = [originPosX,originPosY,secondPosX,secondPosY,rotation,invertMode];
  reset();

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
