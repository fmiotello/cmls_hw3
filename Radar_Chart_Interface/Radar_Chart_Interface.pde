
/*----------------------------------------------------------------------------------------------
RadarChart inspired from the layout available on : https://github.com/pavanred/Radar-chart-utility-
----------------------------------------------------------------------------------------------------*/

RadarChart rc;

PointValue[] chartPoints;
Axis[] axes;
int dimNumber;
int intervalNumber;

int manipulatedDim;
int hooveredDim;


void setup(){  
  
  size(800,600);  //screen size set to 800*600  
  
  // initialise the axis
  dimNumber = 15;
  intervalNumber = 10;
  axes = new Axis[dimNumber];
  axes[0] = new Axis(1,"Dummy0","Quad BTU");
  axes[1] = new Axis(2,"Dummy1","Quad BTu");
  axes[2] = new Axis(3,"Dummy2","Quad BTU");
  axes[3] = new Axis(4,"Dummy3","Mil metric tons");
  axes[4] = new Axis(5,"Dummy4","millions");
  axes[5] = new Axis(6,"Dummy5","millions");
  axes[6] = new Axis(7,"Dummy6","millions");
  axes[7] = new Axis(8,"Dummy7","millions");
  axes[8] = new Axis(9,"Dummy8","millions");
  axes[9] = new Axis(10,"Dummy9","millions");
  axes[10] = new Axis(11,"Dummy10","millions");
  axes[11] = new Axis(12,"Dummy11","millions");
  axes[12] = new Axis(13,"Dummy12","millions");
  axes[13] = new Axis(14,"Dummy13","millions");
  axes[14] = new Axis(15,"Dummy14","millions");
  
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
  
  
  rc = new RadarChart(percentX(25),percentY(15),percentX(50),percentY(70),percentX(5),percentY(5),intervalNumber,dimNumber,percentX(15),percentY(10), axes);
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
    print(manipulatedDim);
    print("\n");
    chartPoints[manipulatedDim].setValue(rc.getLength(mouseX, mouseY,manipulatedDim));

  }
}



void mouseDragged() {
  if(hooveredDim==manipulatedDim){
    print(manipulatedDim);
    print("\n");
    chartPoints[manipulatedDim].setValue(rc.getLength(mouseX, mouseY,manipulatedDim));
  }

}

void mouseReleased() {
}
