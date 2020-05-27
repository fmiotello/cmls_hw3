
/*----------------------------------------------------------------------------------------------
RadarChart inspired from the layout available on : https://github.com/pavanred/Radar-chart-utility-
----------------------------------------------------------------------------------------------------*/
import controlP5.*;
import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;

ControlP5 cp5;
Knob amplitude_knob;
Knob reverb_knob;
Knob attack_knob;
Knob release_knob;

float amplitude;
float reverb;
float attack;
float release;

RadarChart rc;

PointValue[] chartPoints;
Axis[] axes;
int dimNumber;
int intervalNumber;

int manipulatedDim;
int hooveredDim;


void setup(){  
  
  size(800,700);  //screen size set to 800*600  
  
  //initialise the OSC communication
  oscP5 = new OscP5(this, 12000);
  myRemoteLocation = new NetAddress("127.0.0.1", 57120);
  
  // initialise the axis +  each parameter with a default value
  dimNumber = 15;
  intervalNumber = 10;
  
  axes = new Axis[dimNumber];
  axes[0] = new Axis(0,"Fundamental");
  
  chartPoints = new PointValue[dimNumber];
  
  for(int i = 0; i<dimNumber; i++){
    chartPoints[i] = new PointValue(random(1),i);
    if(i!=0){
      axes[i] = new Axis(i,"Harmonic "+i);
    }
  }
  
  
  rc = new RadarChart(percentX(25),percentY(30),percentX(50),percentY(70),percentX(5),percentY(5),intervalNumber,dimNumber,percentX(7),percentY(5), axes);
  
  cp5 = new ControlP5(this);
  amplitude_knob = cp5.addKnob("amplitude")
    .setPosition(percentX(15),percentY(10))
    .setRadius(50)
    .setRange(0,1)
    .setValue(1)
    .setColorForeground(color(201,112,112))
    .setColorBackground(color(240,201,201))
    .setColorActive(color(237,218,218))
    .setColorCaptionLabel(color(20,20,20));
    
  reverb_knob = cp5.addKnob("reverb")
    .setPosition(percentX(35),percentY(10))
    .setRadius(50)
    .setRange(0,1)
    .setValue(0.7)
    .setColorForeground(color(201,112,112))
    .setColorBackground(color(240,201,201))
    .setColorActive(color(237,218,218))
    .setColorCaptionLabel(color(20,20,20));
  
  attack_knob = cp5.addKnob("attack")
    .setPosition(percentX(55),percentY(10))
    .setRadius(50)
    .setRange(0,1)
    .setValue(1)
    .setColorForeground(color(201,112,112))
    .setColorBackground(color(240,201,201))
    .setColorActive(color(237,218,218))
    .setColorCaptionLabel(color(20,20,20));
  
  release_knob = cp5.addKnob("release")
    .setPosition(percentX(75),percentY(10))
    .setRadius(50)
    .setRange(0,1)
    .setValue(1)
    .setColorForeground(color(201,112,112))
    .setColorBackground(color(240,201,201))
    .setColorActive(color(237,218,218))
    .setColorCaptionLabel(color(20,20,20));
}

void draw(){
  setupBackground();
  rc.drawChart(); //draw the skeleton chart. 
  rc.addValuesInChart(chartPoints);
  
  if(mouseX>rc.chartBeginingX && mouseY > rc.chartBeginingY && mouseX < rc.chartBeginingX+rc.chartWidth && mouseY < rc.chartBeginingY+rc.chartHeight ){
    hooveredDim = rc.getAxisNum(mouseX, mouseY);
  }
  
}

void mousePressed() {
  if(mouseX>rc.chartBeginingX && mouseY > rc.chartBeginingY && mouseX < rc.chartBeginingX+rc.chartWidth && mouseY < rc.chartBeginingY+rc.chartHeight ){
    manipulatedDim = rc.getAxisNum(mouseX, mouseY);
    print("manipulating harm : "+manipulatedDim);
    print("\n");
    chartPoints[manipulatedDim].setValue(rc.getLength(mouseX, mouseY,manipulatedDim));

  }
}



void mouseDragged() {
  if(hooveredDim==manipulatedDim){
    //print(manipulatedDim);
    //print("\n");
    chartPoints[manipulatedDim].setValue(rc.getLength(mouseX, mouseY,manipulatedDim));
  }
  
  else if(abs(hooveredDim-manipulatedDim)==1){
    if(rc.getLength(mouseX, mouseY,manipulatedDim)<0.15){
      chartPoints[manipulatedDim].setValue(rc.getLength(mouseX, mouseY,manipulatedDim));
    }
  }

}


void controlEvent(ControlEvent event) {
  OscMessage myMessage = new OscMessage("/knob");
  
  myMessage.add(amplitude);
  myMessage.add(reverb);
  myMessage.add(attack);
  myMessage.add(release);
  
  oscP5.send(myMessage, myRemoteLocation);
  myMessage.print();
}
