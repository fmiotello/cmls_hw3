// TODO : 
//
//  - branch in spider web
//  - set number harmo ( set the lasts to 0 + trransmit it and the number of harmos)
//  - parameters for colors
//



/*----------------------------------------------------------------------------------------------
 RadarChart inspired from the layout available on : https://github.com/pavanred/Radar-chart-utility- (but practically entirely recorded)
 ----------------------------------------------------------------------------------------------------*/
import controlP5.*;
import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;

ControlP5 cp5;
Knob amplitude_knob;
Knob reverb_knob;
Slider harmonicsNumber_slider;
Textlabel harmonicNumberLabel;
Knob attack_knob;
Knob release_knob;

float master_volume;
float spider_effect;
int harmonics_number;
float attack;
float release;

RadarChart rc;

PointValue[] chartPoints;
Axis[] axes;
int dimNumber;
int intervalNumber;

int manipulatedDim;
int hooveredDim;

PImage spider;
PImage spider_cursor;
float panX;
Boolean panSetting;

int backgroundColor;
int webColor;
int webPointColor;
int plotShapeColor;
int plotShapeFillColor;
int plotShapeTranslucidity;
int selectedBranchColor;

void setup() {  

  size(800, 800);  //screen size set to 800*800
  
  // COLORS for the spiderPlot (directly in the setup (e.g for the knobs))
  backgroundColor = #000000;
  webColor = #ADA5A8;
  webPointColor = #A80F52;
  plotShapeTranslucidity = 70; // %
  plotShapeColor = #ffffff;
  plotShapeFillColor = #ffdf00;
  selectedBranchColor = #000000;

  //initialise the OSC communication
  oscP5 = new OscP5(this, 12000);
  myRemoteLocation = new NetAddress("127.0.0.1", 57120);

  // initialise the axis +  each parameter with a default value
  dimNumber = 15;
  intervalNumber = 10;

  axes = new Axis[dimNumber];
  axes[0] = new Axis(0, "Fundamental");

  chartPoints = new PointValue[dimNumber];

  for (int i = 0; i<dimNumber; i++) {
    chartPoints[i] = new PointValue(random(1), i);
    if (i!=0) {
      axes[i] = new Axis(i, "Harmonic "+i);
    }
  }

  // create the radarChart instance which permit to manipulate and draw the radar plot.
  rc = new RadarChart(percentX(25), percentY(25), percentX(50), percentY(60), percentX(5), percentY(5), intervalNumber, dimNumber, percentX(7), percentY(5), axes);

  // create our knobs.
  cp5 = new ControlP5(this);
  

  harmonicsNumber_slider = cp5.addSlider("harmonics_number");  // needs to be defined before other knobs because of the if statement in the ControlEvent method.
    harmonicsNumber_slider
    .setPosition(percentX(49), percentY(12))
    .setRange(5, 15)
    .setSize(percentX(3),percentY(12))
    .setValue(10)
    .setCaptionLabel("")
    .setColorForeground(color(201, 112, 112))
    .setColorBackground(color(240, 201, 201))
    .setColorActive(color(237, 218, 218))
    .setColorCaptionLabel(color(20, 20, 20));
    
  harmonicNumberLabel = cp5.addLabel("HARMONIC NUMBER")
    .setPosition(percentX(44), percentY(25))
    .setColor(0)
    .setFont(createFont("Arial", 9));
   
  amplitude_knob = cp5.addKnob("master_volume")
    .setPosition(percentX(10), percentY(10))
    .setRadius(50)
    .setRange(0, 1)
    .setValue(1)
    .setColorForeground(color(201, 112, 112))
    .setColorBackground(color(240, 201, 201))
    .setColorActive(color(237, 218, 218))
    .setColorCaptionLabel(color(20, 20, 20));

  reverb_knob = cp5.addKnob("spider_effect")
    .setPosition(percentX(30), percentY(10))
    .setRadius(50)
    .setRange(0, 1)
    .setValue(0.7)
    .setColorForeground(color(201, 112, 112))
    .setColorBackground(color(240, 201, 201))
    .setColorActive(color(237, 218, 218))
    .setColorCaptionLabel(color(20, 20, 20));

  attack_knob = cp5.addKnob("attack")
    .setPosition(percentX(60), percentY(10))
    .setRadius(50)
    .setRange(0, 1)
    .setValue(1)
    .setColorForeground(color(201, 112, 112))
    .setColorBackground(color(240, 201, 201))
    .setColorActive(color(237, 218, 218))
    .setColorCaptionLabel(color(20, 20, 20));

  release_knob = cp5.addKnob("release")
    .setPosition(percentX(80), percentY(10))
    .setRadius(50)
    .setRange(0, 1)
    .setValue(1)
    .setColorForeground(color(201, 112, 112))
    .setColorBackground(color(240, 201, 201))
    .setColorActive(color(237, 218, 218))
    .setColorCaptionLabel(color(20, 20, 20));

  // load the spider image for the pan setting and the cursor when hoovering the spider plot.
  spider = loadImage("pan.png");
  spider_cursor = loadImage("spider.png");
  spider_cursor.resize(25,35);
  panX = width/2;
  panSetting = false;
}

void draw() {
  setupBackground();
  rc.drawChart(); //draw the skeleton chart. 
  rc.addValuesInChart(chartPoints);  // draw the value over the skeleton.

  // get the hoovered axis if hoovering the web
  if (mouseX>rc.chartBeginingX && mouseY > rc.chartBeginingY && mouseX < rc.chartBeginingX+rc.chartWidth && mouseY < rc.chartBeginingY+rc.chartHeight ) {
    hooveredDim = rc.getAxisNum(mouseX, mouseY);
  }
  
  // draw the spider to set the paning, at the abscisse corresponding to the actual paning
  image(spider, panX-percentX(5), percentY(85),percentX(10),percentY(10));
  if (!panSetting) {
    PFont myFont = createFont("SansSerif", 12);
    textFont(myFont);
    fill(#000000);  
    textAlign(CENTER, CENTER);
    text("Pan me", panX, percentY(96));
  }
  // set the shape of the cursor accordingly to what is hoovered currently.
  if (mouseX>rc.chartBeginingX && mouseY > rc.chartBeginingY && mouseX < rc.chartBeginingX+rc.chartWidth && mouseY < rc.chartBeginingY+rc.chartHeight ) {
    cursor(spider_cursor,0,0);
  } else if (mouseY>percentY(85) && mouseY<percentY(95) && mouseX>panX-percentX(5) && mouseX<panX+percentX(5)) {
    cursor(HAND);
  } else {
    cursor(ARROW);
  }
}

void mousePressed() {
  if (mouseX>rc.chartBeginingX && mouseY > rc.chartBeginingY && mouseX < rc.chartBeginingX+rc.chartWidth && mouseY < rc.chartBeginingY+rc.chartHeight ) {
    manipulatedDim = rc.getAxisNum(mouseX, mouseY);
    print("manipulating harm : "+manipulatedDim);
    print("\n");
    chartPoints[manipulatedDim].setValue(rc.getLength(mouseX, mouseY, manipulatedDim));
  }
  if (mouseY>percentY(85) && mouseY<percentY(95) && mouseX>panX-percentX(5) && mouseX<panX+percentX(5)) {
    panSetting = true;  // we are now setting the pan parameter
  }
}



void mouseDragged() {
  if (hooveredDim==manipulatedDim) {
    //print(manipulatedDim);
    //print("\n");
    chartPoints[manipulatedDim].setValue(rc.getLength(mouseX, mouseY, manipulatedDim));
  } else if (abs(hooveredDim-manipulatedDim)==1) {
    if (rc.getLength(mouseX, mouseY, manipulatedDim)<0.15) {
      chartPoints[manipulatedDim].setValue(rc.getLength(mouseX, mouseY, manipulatedDim));
    }
  }
  if (panSetting) {
    setPanX(mouseX);
  }
}

void mouseReleased() {
  panSetting=false; // we are not setting the pan parameter anymore.
}


void controlEvent(ControlEvent event) {
  
  if(event.getName()==harmonicsNumber_slider.getName()){
    OscMessage myMessage = new OscMessage("/harmonicsNumber");
    myMessage.add(harmonics_number);
    oscP5.send(myMessage, myRemoteLocation);
    myMessage.print();
  }
  
  else{
    OscMessage myMessage = new OscMessage("/knob");
  
    myMessage.add(master_volume);
    myMessage.add(spider_effect);
    myMessage.add(attack);
    myMessage.add(release);
  
    oscP5.send(myMessage, myRemoteLocation);
    myMessage.print();
  }
  
}

void setPanX(float _panX) {
  if (_panX>percentX(47) && _panX<percentX(53)) {
    panX = percentX(50);
  } else if (_panX>percentX(10) && _panX<percentX(90)) {
    panX = _panX;
  } else if (_panX<percentX(10)) {
    panX = percentX(10);
  } else if (_panX>percentX(90)) {
    panX = percentX(90);
  }
  OscMessage myMessage = new OscMessage("/pan");
  myMessage.add(normalizedPanX(panX));
  oscP5.send(myMessage, myRemoteLocation);
  myMessage.print();
}

float normalizedPanX(float _panX) {   // normalise panX between -1 and +1
  return(((_panX-percentX(10))/percentX(40))-1);
}
