boolean shaderPerVoxel = false;

FBVoxel voxel;

void setup(){
  voxel = new FBVoxel("tree.txt");
  exit();
}

class FBVoxel {

  ArrayList p, c, ci;
  Data input;
  Data output;
  Data mayaHeader;

  FBVoxel(String _s) {
    p = new ArrayList();
    c = new ArrayList();
    ci = new ArrayList();
    input = new Data();
    output = new Data();
    mayaHeader = new Data();

    //1.  Parse input file.    
    try {
      input.load(_s);
      for (int i=0;i<input.data.length;i++) {
        try{
          String curLine = input.data[i];
          if(curLine.charAt(0)!=char('#')){
            extractData(curLine);
          }
        }catch(Exception e){ }
      }
    }catch(Exception e) {
      println("Couldn't load input file.");
    }
    
    //2.  Generate output file.
    try{
      output.beginSave();
      //Maya functions
      mayaHeader.load("mayaHeader.py");
      for(int i=0;i<mayaHeader.data.length;i++){
        output.add(mayaHeader.data[i]);
      }
      output.add("");
      //create shaders
      ArrayList shaders = new ArrayList();
      if(shaderPerVoxel){
        //looks up colors using the index arraylist
        for(int i=0;i<ci.size();i++){
          int index = (Integer) ci.get(i);
          color cc = getColor(c,index);
          int a = (cc >> 24) & 0xFF;
          int r = (cc >> 16) & 0xFF;
          int g = (cc >> 8) & 0xFF;
          int b = cc & 0xFF;
          //~~
          String s = "shader" + (i+1);
          shaders.add(s);
          output.add(s + " = createShader(\"blinn\",["+r+","+g+","+b+","+a+"],False)");
          println(s);
        }
      }else{
        //looks up colors using the index arraylist
        for(int i=0;i<c.size();i++){
          color cc = getColor(c,i);
          int a = (cc >> 24) & 0xFF;
          int r = (cc >> 16) & 0xFF;
          int g = (cc >> 8) & 0xFF;
          int b = cc & 0xFF;
          //~~
          String s = "shader" + (i+1);
          shaders.add(s);
          output.add(s + " = createShader(\"blinn\",["+r+","+g+","+b+","+a+"],False)");
          println(s);
        }
      }
      output.add("");
      //~~  
      for(int i=0;i<p.size();i++){
        output.add("polyCube()");
        //~~
        PVector pp = (PVector) p.get(i);
        output.add("move(" + int(pp.x) + "," + int(pp.y) + "," + int(pp.z) + ")");
        //~~
        int index = (Integer) ci.get(i);
        //placeholder for a real Maya Python materials command
        String s = (String) shaders.get(index);
        output.add("assignShader("+ s +")");
        //~~      
      }    
      output.endSave("tree.py");
    }catch(Exception e){
      println("Couldn't write output file.");
    }
  }

  color getColor(ArrayList _c, int _id){
     return (color)(Integer) _c.get(_id);
  }
  
  void extractData(String curLine){
    int spaceCounter = 0;
    String sp = "";
    String sc = "";
    color cc =color(0);
    PVector pp = new PVector(0,0,0);
    for(int j=0;j<curLine.length();j++){
      if(spaceCounter<3){
        if(curLine.charAt(j)==char(' ')){
          if(spaceCounter<2) sp += ",";
          spaceCounter++;
        }else{
          sp += curLine.charAt(j);
        }
      }else{
        if(curLine.charAt(j)==char(' ')){
          if(spaceCounter<6) sc += ",";
          spaceCounter++;
        }else{
          sc += curLine.charAt(j);
        }
      }
    }
    pp = setPVector(sp);
    cc = setColor(sc);
    int index = 0;
    boolean match = false;
    for(int k=0;k<c.size();k++){
      color x = getColor(c,k);
      if(cc==x){
        match=true;
        index=k;
      }
    }
    if(!match){
      c.add(cc);
      index = c.size()-1;
    }
    ci.add(index);
    p.add(pp);  
  }

  //~~~~   utilities   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  int setInt(String _s) {
    return int(_s);
  }

  float setFloat(String _s) {
    return float(_s);
  }

  boolean setBoolean(String _s) {
    return boolean(_s);
  }
  
  String setString(String _s) {
    return ""+(_s);
  }
  
  String[] setStringArray(String _s) {
    int commaCounter=0;
    for(int j=0;j<_s.length();j++){
          if (_s.charAt(j)==char(',')){
            commaCounter++;
          }      
    }
    //println(commaCounter);
    String[] buildArray = new String[commaCounter+1];
    commaCounter=0;
    for(int k=0;k<buildArray.length;k++){
      buildArray[k] = "";
    }
    for (int i=0;i<_s.length();i++) {
        if (_s.charAt(i)!=char(' ') && _s.charAt(i)!=char('(') && _s.charAt(i)!=char(')') && _s.charAt(i)!=char('{') && _s.charAt(i)!=char('}') && _s.charAt(i)!=char('[') && _s.charAt(i)!=char(']')) {
          if (_s.charAt(i)==char(',')){
            commaCounter++;
          }else{
            buildArray[commaCounter] += _s.charAt(i);
         }
       }
     }
     println(buildArray);
     return buildArray;
  }

  color setColor(String _s) {
    color endColor = color(0);
    int commaCounter=0;
    String sr = "";
    String sg = "";
    String sb = "";
    String sa = "";
    int r = 0;
    int g = 0;
    int b = 0;
    int a = 0;

    for (int i=0;i<_s.length();i++) {
        if (_s.charAt(i)!=char(' ') && _s.charAt(i)!=char('(') && _s.charAt(i)!=char(')')) {
          if (_s.charAt(i)==char(',')){
            commaCounter++;
          }else{
          if (commaCounter==0) sr += _s.charAt(i);
          if (commaCounter==1) sg += _s.charAt(i);
          if (commaCounter==2) sb += _s.charAt(i); 
          if (commaCounter==3) sa += _s.charAt(i);
         }
       }
     }

    if (sr!="" && sg=="" && sb=="" && sa=="") {
      r = int(sr);
      endColor = color(r);
    }
    if (sr!="" && sg!="" && sb=="" && sa=="") {
      r = int(sr);
      g = int(sg);
      endColor = color(r, g);
    }
    if (sr!="" && sg!="" && sb!="" && sa=="") {
      r = int(sr);
      g = int(sg);
      b = int(sb);
      endColor = color(r, g, b);
    }
    if (sr!="" && sg!="" && sb!="" && sa!="") {
      r = int(sr);
      g = int(sg);
      b = int(sb);
      a = int(sa);
      endColor = color(r, g, b, a);
    }
      return endColor;
  }
  
  PVector setPVector(String _s){
    PVector endPVector = new PVector(0,0,0);
    int commaCounter=0;
    String sx = "";
    String sy = "";
    String sz = "";
    float x = 0;
    float y = 0;
    float z = 0;

    for (int i=0;i<_s.length();i++) {
        if (_s.charAt(i)!=char(' ') && _s.charAt(i)!=char('(') && _s.charAt(i)!=char(')')) {
          if (_s.charAt(i)==char(',')){
            commaCounter++;
          }else{
          if (commaCounter==0) sx += _s.charAt(i);
          if (commaCounter==1) sy += _s.charAt(i);
          if (commaCounter==2) sz += _s.charAt(i); 
         }
       }
     }

    if (sx!="" && sy=="" && sz=="") {
      x = float(sx);
      endPVector = new PVector(x,0);
    }
    if (sx!="" && sy!="" && sz=="") {
      x = float(sx);
      y = float(sy);
      endPVector = new PVector(x,y);
    }
    if (sx!="" && sy!="" && sz!="") {
      x = float(sx);
      y = float(sy);
      z = float(sz);
      endPVector = new PVector(x,y,z);
    }
      return endPVector;
  }
  
}

