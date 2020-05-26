
/*----------------------------------------------------------------------------------------------
RadarChart inspired from the layout available on : https://github.com/pavanred/Radar-chart-utility-
----------------------------------------------------------------------------------------------------*/
import controlP5.*;

ControlP5 cp5;
Knob vintage_knob;
Knob intensity_knob;
Knob filter_knob;

RadarChart rc;

PointValue[] chartPoints;
Axis[] axes;
int dimNumber;
int intervalNumber;

int manipulatedDim;
int hooveredDim;


void setup(){  
  
  size(800,700);  //screen size set to 800*600  
  
  // initialise the axis
  dimNumber = 15;
  intervalNumber = 10;
  axes = new Axis[dimNumber];
  axes[0] = new Axis(1,"Fundamental");
  axes[1] = new Axis(2,"Harmonic 1");
  axes[2] = new Axis(3,"Harmonic 2");
  axes[3] = new Axis(4,"Harmonic 3");
  axes[4] = new Axis(5,"Harmonic 4");
  axes[5] = new Axis(6,"Harmonic 5");
  axes[6] = new Axis(7,"Harmonic 6");
  axes[7] = new Axis(8,"Harmonic 7");
  axes[8] = new Axis(9,"Harmonic 8");
  axes[9] = new Axis(10,"Harmonic 9");
  axes[10] = new Axis(11,"Harmonic 10");
  axes[11] = new Axis(12,"Harmonic 11");
  axes[12] = new Axis(13,"Harmonic 12");
  axes[13] = new Axis(14,"Harmonic 13");
  axes[14] = new Axis(15,"Harmonic 14");
  
  // initialise each parameter with a default value
  chartPoints = new PointValue[dimNumber];
  chartPoints[0] = new PointValue(0.4);
  chartPoints[1] = new PointValue(0.5);
  chartPoints[2] = new PointValue(0.2);
  chartPoints[3] = new PointValue(0.2);
  chartPoints[4] = new PointValue(0.9);
  chartPoints[5] = new PointValue(0.5);
  chartPoints[6] = new PointValue(0.8);
  chartPoints[7] = new PointValue(0.2);
  chartPoints[8] = new PointValue(0.8);
  chartPoints[9] = new PointValue(0.8);
  chartPoints[10] = new PointValue(0.8);
  chartPoints[11] = new PointValue(0.8);
  chartPoints[12] = new PointValue(0.8);
  chartPoints[13] = new PointValue(0.8);
  chartPoints[14] = new PointValue(0.8);
  
  
  rc = new RadarChart(percentX(25),percentY(30),percentX(50),percentY(70),percentX(5),percentY(5),intervalNumber,dimNumber,percentX(7),percentY(5), axes);
  
  cp5 = new ControlP5(this);
  vintage_knob = cp5.addKnob("vintage")
    .setPosition(percentX(20),percentY(10))
    .setRadius(50)
    .setRange(0,1)
    .setValue(1)
    .setColorForeground(color(201,112,112))
    .setColorBackground(color(240,201,201))
    .setColorActive(color(237,218,218))
    .setColorCaptionLabel(color(20,20,20));
    
  intensity_knob = cp5.addKnob("intensity")
    .setPosition(percentX(45),percentY(10))
    .setRadius(50)
    .setRange(0,1)
    .setValue(0.7)
    .setColorForeground(color(201,112,112))
    .setColorBackground(color(240,201,201))
    .setColorActive(color(237,218,218))
    .setColorCaptionLabel(color(20,20,20));
  
  filter_knob = cp5.addKnob("filter")
    .setPosition(percentX(70),percentY(10))
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

void mouseReleased() {
}
