let originPosX;
let originPosY;
let secondPosX;
let secondPosY;

let rotStart;
let rotation = 0;
let rotToMouse =0;

let polyVertexes = [];

let node;
let junction;

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
  canvas.position(90,540)

  OSCjunction.connect("node-1", connectNodeSuccess, fail);

  ellipseMode(CORNERS);
  rectMode(CORNERS);

  shapeType = createRadio();
  shapeType.option('ellipse');
  shapeType.option('rectangle');
  shapeType.option('polygon');
  shapeType.value('rectangle');
  shapeType.position(900,600)


  drawMode = createRadio();
  drawMode.option('draw',1);
  drawMode.option('rotate',2);
  drawMode.value('1');
  drawMode.position(900,700)

  farbMode = createCheckbox('invert Colors', false);
  farbMode.position(950,545)

  colorPicker = createColorPicker('#ed225d');
  colorPicker.position(900,545);

  sendButton = createButton('Send');
  sendButton.position(900,800);
  sendButton.mousePressed(sendOut);

  noLoop();
}



function draw() {
  background(220);


  fill(colorPicker.color());
  print(red(colorPicker.value()),green(colorPicker.value()),blue(colorPicker.value()));

  maxSize = 100;



  if (drawMode.value() == 1) {

    print("lol",drawMode.value());
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

    if (shapeType.value() == "ellipse") {
      ellipse(originPosX, originPosY, secondPosX, secondPosY);
    } else if (shapeType.value() == "rectangle") {
      rect(originPosX, originPosY, secondPosX, secondPosY);
    } else if (shapeType.value() == "polygon") {


      beginShape();

      for (let i = 0; i < polyVertexes.length; i++) {
        vertex(polyVertexes[i][0], polyVertexes[i][1]);
      }
      endShape();

    }
  } else if (drawMode.value() == 2) {
    
    push();
    

    
    if(shapeType.value() == "ellipse") {
      
      let centerPointX = originPosX+(secondPosX-originPosX)/2;
      let centerPointY = originPosY+(secondPosY-originPosY)/2;
        
      rotToMouse = atan2(mouseY - centerPointY, mouseX - centerPointX);
      if(rotStart){
        rotation = rotToMouse-rotation;
        rotStart = false;
      }
      
      translate(centerPointX,centerPointY);
      //rotate(mouseX/width*2*PI);
      rotate(rotToMouse-rotation);
      
      ellipseMode(CENTER); 
      ellipse(0,0,secondPosX-originPosX,secondPosY-originPosY);
      
    }else if(shapeType.value() == "rectangle") {
      
      let centerPointX = originPosX+(secondPosX-originPosX)/2;
      let centerPointY = originPosY+(secondPosY-originPosY)/2;
          
      rotToMouse = atan2(mouseY - centerPointY, mouseX - centerPointX);
      if(rotStart){
        rotation = rotToMouse-rotation;
        rotStart = false;
      }
      
      translate(centerPointX,centerPointY);
      //rotate(mouseX/width*2*PI);
      rotate(rotToMouse-rotation);
      
      rectMode(CENTER); 
      rect(0,0,secondPosX-originPosX,secondPosY-originPosY);
      
    }else if(shapeType.value() == "polygon") {
      
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
    
      
      rotToMouse = atan2(mouseY - centerPointY, mouseX - centerPointX);
      if(rotStart){
        rotation = rotToMouse-rotation;
        rotStart = false;
      }
      
      translate(centerPointX,centerPointY);
      //rotate(mouseX/width*2*PI);
      rotate(rotToMouse-rotation);
      
      
      beginShape();

      for (let i = 0; i < polyVertexes.length; i++) {
        vertex(polyVertexes[i][0]-centerPointX, polyVertexes[i][1]-centerPointY);
      }
      endShape();
    
    }
    
    pop();

  }

}


function mousePressed() {
  if (mouseX > 0 && mouseX < width && mouseY > 0 && mouseY < height) {
    if (shapeType.value() == "polygon" && drawMode.value() == 1) {
      polyVertexes.push([mouseX, mouseY]);

    } else if(drawMode.value() == 1) {
    
      originPosX = mouseX;
      originPosY = mouseY;
      print("mouse is pressed");
    
    } else if(drawMode.value() == 2){
            
      rotStart=true;
    
    }
    redraw();
  }

}

function mouseDragged() {

  redraw();
}


function mouseReleased(){

  rotation = rotToMouse-rotation;

}



function sendOut(){

  if(junction !== undefined && junction.connected) {
    let invertMode;

    if(farbMode.checked())
      invertMode=1;
    else
      invertMode=0;
    
    if(shapeType.value()=='rectangle')
      junction.send("/rect", [originPosX,originPosY,secondPosX,secondPosY,rotation,invertMode,red(colorPicker.value()),green(colorPicker.value()),blue(colorPicker.value())]);
    else if(shapeType.value()=='ellipse')
      junction.send("/ellipse", [originPosX,originPosY,secondPosX,secondPosY,rotation,invertMode,red(colorPicker.value()),green(colorPicker.value()),blue(colorPicker.value())]);
    else {
      let args =[rotation,invertMode,red(colorPicker.value()),green(colorPicker.value()),blue(colorPicker.value())];
      
      for (let i = 0; i < polyVertexes.length; i++) {
        args.push(polyVertexes[i][0]);
        args.push(polyVertexes[i][1]);
      }
      junction.send("/poly",args);

  }





  }

}



/*ToDo

triangle vllt irgendwann, nicht wichtig


*/