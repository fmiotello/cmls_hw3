//basic utility methods used in setup() and draw()

void setupBackground(){
  
  background(#012437);  //background color dark blue
 
  //Header label
  PFont spiderFont = createFont("Bebas-Regular.ttf", 50);
  textFont(spiderFont);
  fill(#FEA001);  
  textAlign(CENTER, CENTER);
  text("SYNTHESPIDER",percentX(50), percentY(6));   
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
  
  Axis(int _id, String _name){
    id = _id;
    Name = _name;
  }
}


class PointValue{

  float value;  //between 0 and 1
  float harmonicNumber;
  
  PointValue(float _value, int _harmonicNumber){    // harmonicNumber 0 = fundamental
    value = _value;
    harmonicNumber = _harmonicNumber;
    if(value>1){
      print("ERROR VALUE : value>1\n");
    }
    OscMessage myMessage = new OscMessage("/harmonic");
    
    myMessage.add(this.harmonicNumber);
    myMessage.add(this.value);
    
    oscP5.send(myMessage, myRemoteLocation);
    myMessage.print();
  }
  void setValue(float _value){
    if(_value!=-1){
      this.value = _value;
      
      OscMessage myMessage = new OscMessage("/harmonic");
      
      myMessage.add(this.harmonicNumber);    // harmonicNumber 0 = fundamental
      myMessage.add(this.value);
      
      oscP5.send(myMessage, myRemoteLocation);
      myMessage.print();
    }
  }
}
