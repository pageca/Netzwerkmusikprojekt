

p = NetAddr("127.0.0.1", 12000); // Processing-Port


//neue Figuren erstellen:
p.sendMsg("/new_shape","ELLIPSE",200.0,200.0,100.0,100.0); //[posX, posY, heigth, width] | ALLE ALS FLOAT, sonst error

p.sendMsg("/new_shape","RECT",300.0,300.0,500.0,500.0); //[posX, posY, heigth, width] | pos is upperleft corner  | ALLE ALS FLOAT, sonst error



p.sendMsg("/color_shape",0,100,0,100);//[ID,red,green,blue] | ID zählt von 0 hoch und wird beim Erstellen(/new_shape) zugewiesen


p.sendMsg("/move_shape",0, 20, 10);// [ID,x,y] moves the shape x in X-Direction and y in Y-Direction. negatives allowed






