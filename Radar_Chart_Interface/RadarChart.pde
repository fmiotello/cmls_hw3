class RadarChart{
  
  float chartBeginingX;
  float chartBeginingY;
  float chartWidth;
  float chartHeight;
  float angleStep;
  float marginWidth;
  float marginHeight;
  float centerX;
  float centerY;
  float axisLength;
  int intervals;
  float intervalLength;
  int distance = 5;
  int dimensions;
  int labelWidth;
  int labelHeight;
  float[] axisPointsX;
  float[] axisPointsY;
  Axis[] axeList;
  
  ////Constructor - sets margin width, margin height, number of intervals on the axes to default values
  //RadarChart(float _X, float _Y, float _chartWidth, float _chartHeight,int dim){
  //  
  //  dimensions = dim; 
  //  angleStep = 360 / dim;
  //  marginWidth = 50;  //default values - edit defaults of use the construtor over load.
  //  marginHeight = 50; //default values - edit defaults of use the construtor over load.
  //  X = _X + marginWidth;
  //  Y = _Y + marginHeight;
  //  chartWidth = _chartWidth - (marginWidth * 2);
  //  chartHeight = _chartHeight - (marginHeight * 2);
  //  centerX = _X + (_chartWidth/2);
  //  centerY = _Y + (_chartHeight/2);
  //  axisLength = chartHeight/2 - marginHeight;
  //  intervals = 5; //number of intervals on the axes
  //  intervalLength = axisLength/float(intervals);
  //  
  //}
  
  //Constructor - accepts all user input values
  RadarChart(float _chartBegX, float _chartBegY, float _chartWidth, float _chartHeight, float _marginWidth, float _marginHeight, 
            int _intervals, int dim, int lblWidth, int lblHeight, Axis[] _axeList){
 
    dimensions = dim; 
    angleStep = 360 / dim;
    marginWidth = _marginWidth;
    marginHeight = _marginHeight;
    chartBeginingX = _chartBegX + marginWidth;
    chartBeginingY = _chartBegY + marginHeight;
    chartWidth = _chartWidth - (marginWidth * 2);
    chartHeight = _chartHeight - (marginHeight * 2);
    centerX = _chartBegX + (_chartWidth/2);
    centerY = _chartBegY + (_chartHeight/2);
    axisLength = chartHeight/2 - marginHeight;
    intervals = _intervals;
    intervalLength = axisLength/float(intervals);
    labelHeight = lblHeight;
    labelWidth = lblWidth;
    axeList = _axeList;
  }
  
  //void setDimensions(int dim){  //to change the number of dimensions of the chart dynamically. Chart will have to be redrawn after this or drawChart() should be invoked in draw()
  //  dimensions = dim;
  //  angleStep = 360 / dimensions;
  //}
  
  void drawChart(){
    
    stroke(0);
    strokeWeight(4);
    point(centerX,centerY);
    
    axisPointsX = new float[dimensions];
    axisPointsY = new float[dimensions];
    float xValue;
    float yValue;
    float angle = -90;
 
    for(int i = 0; i < dimensions; i++, angle += angleStep){  //increment angle of the axis/dimension drawn i.e. increment by 360/3 deg for a chart of 3 dimentions/axis

      float len = intervalLength;
      axisPointsX[i] = getX(angle, axisLength + labelHeight/3);
      axisPointsY[i] = getY(angle, axisLength + labelHeight/3);
      
      // drawing the axis
      if(i==hooveredDim){
        stroke(selectedBranchColor);
        strokeWeight(1.2);
        line(centerX,centerY,axisPointsX[i],axisPointsY[i]);    //draw the axis line
      }
      else{
        stroke(webColor);
        strokeWeight(1);
        line(centerX,centerY,axisPointsX[i],axisPointsY[i]);    //draw the axis line
      }
      
      stroke(0);
      
      displayLabels(angle, axeList[i]); 
      
      for(int index = 0; index < intervals; index++, len += intervalLength){  //for each interval
        xValue = getX(angle, len);
        yValue = getY(angle, len);
        
        if(index == intervals/2-1 || index == intervals-1){
          strokeWeight(4);  //mark all the interval points on the axes drawn
          stroke(webPointColor);}
        else{
          strokeWeight(4);  //mark all the interval points on the axes drawn
          stroke(webColor);}
        point(xValue,yValue);
        strokeWeight(1);
        line(getX(angle-angleStep, len),getY(angle-angleStep, len),xValue,yValue);
      }    
    }
  }
  
  
  void addValuesInChart(PointValue[] pointValues){
    float angle = -90;
    strokeWeight(1);
    stroke(plotShapeColor);
    fill(plotShapeFillColor, plotShapeTranslucidity);
    beginShape();
    for(int i = 0; i < dimensions; i++, angle += angleStep){
      vertex(getX(angle, axisLength*pointValues[i].value), getY(angle, axisLength*pointValues[i].value));
      
    }
    endShape(CLOSE);
  }
  
  //get the x-axis co-ordinate of a point on the axis/dimension being drawn in the radar chart
  private float getX(float ang, float len){
    return (centerX + (len * cos(radians(ang))));    
  }
  
  //get the x-axis co-ordinate of a point on the axis/dimension being drawn in the radar chart
  private float getY(float ang, float len){
    return (centerY + (len * sin(radians(ang))));
  }  
 
  //get the number of the hoovered axis
  private int getAxisNum(float _mouseX, float _mouseY){
    float actualAngleDegree = (angleStep/2) + 90 + 180*atan2(_mouseY-centerY,_mouseX-centerX)/PI;
    if(actualAngleDegree<0){
      actualAngleDegree+=360.0;
    }
    int actualDim = floor(actualAngleDegree/angleStep);
    if(actualDim == dimensions){actualDim=0;}
    return (actualDim);
  }  
  
  //get the position of the mouse along the axis
  private float getLength(float _mouseX, float _mouseY, int _dimNum){
    float angle = _dimNum*angleStep;
    float actualLength = sqrt(pow((_mouseX-centerX),2)+pow((_mouseY-centerY),2))/axisLength;
    if(actualLength > 1){
      if(actualLength < 1.05){
        actualLength=1;
      }
      else{
      actualLength=-1;
      }
    }
    return(actualLength);
  } 
 
 /*display labels at the end of each axis. 
 To avoid the labels from overlapping over its own axis. The labels are positioned according to the quardant they are present in.
 I quadrant - text aligned left and bottom
 II quadrant - text aligned left and bottom but extra padding provided to the x and y co ordinates
 III quadrant - txt aligned left and bottom with padding to the y axis and x axis co-ordinate reduced by a label's width
 IV quadrant - text aligned left and bottom and x axis co-ordinate  reduced by a label's width 
 */ 
 
 private void displayLabels(float ang, Axis axis){
    float xValue = getX(ang, axisLength + labelHeight/4);
    float yValue = getY(ang, axisLength + labelHeight/4);
      
    PFont myFont = createFont("Bebas-Regular.ttf", 13);
          textFont(myFont);
          fill(#FFFFFF);   
          textAlign(CENTER, TOP);                      
                    
     if(ang >= 0 && ang < 90){
       textAlign(LEFT, BOTTOM);
       text(axis.Name, xValue + labelWidth/6,yValue + labelHeight/4);        
     }
     if(ang >= 90 && ang < 180){    
        textAlign(LEFT, BOTTOM);   
          text(axis.Name, xValue - labelWidth,yValue + labelHeight/2);      
     }
     if(ang >= 180 && ang < 270){     
       textAlign(LEFT, BOTTOM);  
       text(axis.Name, xValue - labelWidth,yValue - labelHeight/6); 
     }
     if((ang >= 270 && ang < 360)||(ang > -90 && ang < 0)){ 
       textAlign(LEFT, BOTTOM);      
       text(axis.Name, xValue,yValue - labelHeight/6); 
     }
     if(ang==-90){
         textAlign(CENTER, BOTTOM); 
         text(axis.Name, xValue,yValue - labelHeight/3); 
     }
  } 
}
