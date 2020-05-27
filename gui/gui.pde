import oscP5.*;
import controlP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;

ControlP5 cp5;
Knob spider_knob;
Button b;

PImage spider_img;

float spider;

void setup() {
  size(500, 500);
  background(255);
  
  smooth();
  noStroke();
  
  oscP5 = new OscP5(this, 12000);
  myRemoteLocation = new NetAddress("127.0.0.1", 57120);

  spider_img = loadImage("spider.jpeg");
  
  cp5 = new ControlP5(this);
  
 spider_knob = cp5.addKnob("spider")
    .setImage(spider_img)
    .setSize(50,50);
}

void draw() {
  background(200,200,200);
}

void controlEvent(ControlEvent theEvent) {
  OscMessage myMessage = new OscMessage("/pos");
  
  myMessage.add(spider);
  
  oscP5.send(myMessage, myRemoteLocation);
  myMessage.print();
}
