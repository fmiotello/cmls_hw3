import oscP5.*;
import controlP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;

ControlP5 cp5;
Knob vintage_knob;
Knob intensity_knob;
Knob filter_knob;

float intensity;
float vintage;
float filter;

void setup() {
  size(400, 200);
  background(255);
  
  smooth();
  noStroke();
  
  oscP5 = new OscP5(this, 12000);
  myRemoteLocation = new NetAddress("127.0.0.1", 57120);
  
  cp5 = new ControlP5(this);
  vintage_knob = cp5.addKnob("vintage")
    .setPosition(25,20)
    .setRadius(50)
    .setRange(0,1)
    .setValue(1)
    .setColorForeground(color(201,112,112))
    .setColorBackground(color(240,201,201))
    .setColorActive(color(237,218,218))
    .setColorCaptionLabel(color(20,20,20));
    
  intensity_knob = cp5.addKnob("intensity")
    .setPosition(150,20)
    .setRadius(50)
    .setRange(0,1)
    .setValue(1)
    .setColorForeground(color(201,112,112))
    .setColorBackground(color(240,201,201))
    .setColorActive(color(237,218,218))
    .setColorCaptionLabel(color(20,20,20));
  
  filter_knob = cp5.addKnob("filter")
    .setPosition(275,20)
    .setRadius(50)
    .setRange(0,1)
    .setValue(1)
    .setColorForeground(color(201,112,112))
    .setColorBackground(color(240,201,201))
    .setColorActive(color(237,218,218))
    .setColorCaptionLabel(color(20,20,20));
}

void draw() {
  background(200,200,200);
}

void controlEvent(ControlEvent theEvent) {
  OscMessage myMessage = new OscMessage("/pos");
  
  myMessage.add(vintage);
  myMessage.add(intensity);
  myMessage.add(filter);
  
  oscP5.send(myMessage, myRemoteLocation);
  myMessage.print();
}
