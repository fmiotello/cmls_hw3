/*----------------------------------------------------------------------------------------------

 * Authors: Federico Miotello, Francesco Castelli, Andriana Takic, Clément Jameau
 * Created:   24.05.2020
 * 
 * Free to be re-used
 
 RadarChart inspired from the skeletton available on : https://github.com/pavanred/Radar-chart-utility-
 ----------------------------------------------------------------------------------------------------*/
import controlP5.*;
import oscP5.*;
import netP5.*;

//variable for OSC communication with the synthetizer
OscP5 oscP5;
NetAddress myRemoteLocation;

//knobs and slider
ControlP5 cp5;
Knob amplitude_knob;
Knob reverb_knob;
Slider harmonicsNumber_slider;
Textlabel harmonicNumberLabel;
Knob attack_knob;
Knob release_knob;

//variables for the knobs/slider
float master_volume;
float spider_effect;
int harmonics_number;
float attack;
float release;

RadarChart rc;

//datas for the radar chart
PointValue[] chartPoints;
Axis[] axes;
int maxDimNumber;
int intervalNumber;

//when manipulating the radar chart...
int manipulatedDim;
int hooveredDim;

//images
PImage spider;
PImage spider_cursor;
//Pan variables
float panX;
Boolean panSetting;

//COLOR variables
int backgroundColor;
int webColor;
int webPointColor;
int plotShapeColor;
int plotShapeFillColor;
int plotShapeTranslucidity;
int selectedBranchColor;
PFont spiderFont;
int foregroundKnobColor;
int backgroundKnobColor;
int activeKnobColor;
int textColor;
int lineColor;
int innerCircleColor;
int sidePanColor;


//COLOR SPECTRUM TO USE
int lightyellow = #F1B434;
int darkyellow = #FEA001;
int lightpurple = #C25B67;
int darkpurple = #6A2537;
int lightblue = #D2E3E6;
int darkblue = #012437;
int middleblue = color(157, 211, 215);

void setup() {  

  size(900, 900);  //screen size set to 800*800
  
  // VISUAL VARIABLES
  webColor = middleblue;
  webPointColor = lightyellow;
  plotShapeTranslucidity = 120; // % NOT A PERCENTAGE, BUT 0:255
  plotShapeColor = darkyellow;
  plotShapeFillColor = lightpurple;
  selectedBranchColor = lightyellow;
  foregroundKnobColor = lightpurple;
  backgroundKnobColor = color(130, 50, 70, 120);
  activeKnobColor = color(167, 211, 215, 180);
  innerCircleColor = color(9,72,100,30);
  sidePanColor = lightpurple;
  textColor = lightblue;
  lineColor = darkyellow;
  spiderFont = createFont("Bebas-Regular.ttf",19);
  

  //initialise the OSC communication
  oscP5 = new OscP5(this, 12000);
  myRemoteLocation = new NetAddress("127.0.0.1", 57120);

  // initialise the axis +  each parameter with a default value
  maxDimNumber = 15;
  intervalNumber = 10;

  axes = new Axis[maxDimNumber];
  axes[0] = new Axis(0, "Fundamental");

  chartPoints = new PointValue[maxDimNumber];

  textFont(spiderFont);
  for (int i = 0; i<maxDimNumber; i++) {
    chartPoints[i] = new PointValue(random(0.1,1), i);
    if (i!=0) {
      axes[i] = new Axis(i, "Harmonic "+i);
    }
  }

  // create the radarChart instance which permit to manipulate and draw the radar plot.
  rc = new RadarChart(percentX(35), percentY(28), percentX(50), percentY(60), percentX(5), percentY(5), intervalNumber, maxDimNumber, percentX(7), percentY(5), axes);

  // create our knobs.
  cp5 = new ControlP5(this);

  harmonicsNumber_slider = cp5.addSlider("harmonics_number");  // needs to be defined before other knobs because of the if statement in the ControlEvent method.
    harmonicsNumber_slider
    .setPosition(percentX(15), percentY(50))
    .setValue(10)
    .setRange(5, 15)
    .setSize(percentX(4),percentY(18))
    .setCaptionLabel("")
    .setColorForeground(foregroundKnobColor)
    .setColorBackground(backgroundKnobColor)
    .setColorActive(activeKnobColor);
      
  harmonicNumberLabel = cp5.addLabel("HARMONIC NUMBER")
    .setPosition(percentX(10), percentY(70))
    .setColor(textColor)
    .setFont(spiderFont); 
   
  amplitude_knob = cp5.addKnob("master_volume")
    .setPosition(percentX(15), percentY(15))
    .setCaptionLabel("master volume")
    .setRadius(50)
    .setRange(0, 1)
    .setValue(1)
    .setColorForeground(foregroundKnobColor)
    .setColorBackground(backgroundKnobColor)
    .setColorActive(activeKnobColor);
    
  cp5.getController("master_volume").getCaptionLabel().setColor(textColor).setFont(spiderFont);

  reverb_knob = cp5.addKnob("spider_effect")
    .setPosition(percentX(35), percentY(15))
    .setCaptionLabel("spider effect")
    .setRadius(50)
    .setRange(0, 1)
    .setValue(0.7)
    .setColorForeground(foregroundKnobColor)
    .setColorBackground(backgroundKnobColor)
    .setColorActive(activeKnobColor);

  cp5.getController("spider_effect").getCaptionLabel().setColor(textColor).setFont(spiderFont);

  attack_knob = cp5.addKnob("attack")
    .setPosition(percentX(55), percentY(15))
    .setRadius(50)
    .setRange(0, 1)
    .setValue(0.2)
    .setColorForeground(foregroundKnobColor)
    .setColorBackground(backgroundKnobColor)
    .setColorActive(activeKnobColor);
    
  cp5.getController("attack").getCaptionLabel().setColor(textColor).setFont(spiderFont);
 
  release_knob = cp5.addKnob("release")
    .setPosition(percentX(75), percentY(15))
    .setRadius(50)
    .setRange(0, 1)
    .setValue(0.5)
    .setColorForeground(foregroundKnobColor)
    .setColorBackground(backgroundKnobColor)
    .setColorActive(activeKnobColor);
    
  cp5.getController("release").getCaptionLabel().setColor(textColor).setFont(spiderFont); 

  // load the spider image for the pan setting and the cursor when hoovering the spider plot.
  spider = loadImage("pan.png");
  spider_cursor = loadImage("spider.png");
  // spider_cursor.resize(25,35);
  panX = width/2;
  panSetting = false;
}

void setGradient(int x, int y, float w, float h, color c1, color c2, int axis ) {

  noFill();

  if (axis == 1) {  // Top to bottom gradient
    for (int i = y; i <= y+h; i+=2) {
      float inter = map(i, y, y+h, 0, 1);
      color c = lerpColor(c1, c2, inter);
      stroke(c);
      line(x, i, x+w, i);
    }
  }  
  else if (axis == 2) {  // Left to right gradient
    for (int i = x; i <= x+w; i+=2) {
      float inter = map(i, x, x+w, 0, 1);
      color c = lerpColor(c1, c2, inter);
      stroke(c);
      line(i, y, i, y+h);
    }
  }
}


void draw() {
  setupBackground();
  
  rc.drawChart(); //draw the skeleton chart. 
  rc.addValuesInChart(chartPoints);  // draw the value over the skeleton.
  
  stroke(lineColor);
  fill(darkblue);
  strokeWeight(2);
  rect(percentX(2), percentY(84), percentX(96), percentY(14), 10);
  
  strokeWeight(3);
  rect(percentX(10), percentY(13), percentX(80), percentY(18), 10);
  
  
  setGradient(20, percentY(85), 430, percentY(12), darkblue, sidePanColor, 2);
  setGradient(450, percentY(85), 430, percentY(12), sidePanColor, darkblue, 2);


  // get the hoovered axis if hoovering the web
  if (mouseX>rc.chartBeginingX && mouseY > rc.chartBeginingY && mouseX < rc.chartBeginingX+rc.chartWidth && mouseY < rc.chartBeginingY+rc.chartHeight ) {
    hooveredDim = rc.getAxisNum(mouseX, mouseY);
  }
  
  
  // draw the spider to set the paning, at the abscisse corresponding to the actual paning
  image(spider, panX-percentX(5), percentY(85),percentX(10),percentY(10));
  textFont(spiderFont);
  fill(textColor);  
  if (!panSetting) {
    textAlign(CENTER, CENTER);
    text("PAN ME", panX, percentY(96));
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
    rc.dimensions = harmonics_number; 
    rc.angleStep = 360 / harmonics_number;
    for(int i = harmonics_number; i<maxDimNumber; i++){
      chartPoints[i].setValue(0);
    }
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

// When receiving an osc message, it means superCollider just launched, so we need to relaunch the interface by relauching the setup() to re-send all the values of the parameters.
/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  /* print the address pattern and the typetag of the received OscMessage */
  print("### received an osc message.");
  print(" addrpattern: "+theOscMessage.addrPattern());
  println(" typetag: "+theOscMessage.typetag());
  
  print("RELAUNCHING..........................................",percentX(50),percentY(50));
  
  delay(500);
  
  frameCount = -1;    // That way we relaunch the setup() !
}
