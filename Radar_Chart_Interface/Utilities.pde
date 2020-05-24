//basic utility methods used in setup() and draw()

void setupBackground(){
  
  background(#FFFFFF);  //back ground color white
 
  // Header label
  PFont myFont = createFont("SansSerif", 15);
  textFont(myFont);
  fill(#000000);  
  textAlign(CENTER, CENTER);
  text("Radar Chart HW3",percentX(50), percentY(5));   
}

//methods to use percentage instead of absolute values
//X - axis
int percentX(int value){
  return (value * width)/100;
}
//Y - axis
int percentY(int value){
  return (value * height)/100;
}

/*-----------------------------------------------
-------------------------------------------------*/

// I have to make it one class

class Axis{

  int id;
  String Name;
  String Unit;
  
  Axis(int _id, String _name, String _unit){
    id = _id;
    Name = _name;
    Unit = _unit;
  }
}


class PointValue{

  float value;  //between 0 and 1
  
  PointValue(float _value){
    value = _value;
    if(value>1){
      print("WARNING : value>1\n");
    }
  }
  void setValue(float _value){
    if(_value!=-1){
      value = _value;
    }
  }
}
