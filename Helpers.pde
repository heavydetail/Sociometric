//Helper Functions
PImage loadRandomPhoto() {
  File [] files;
  java.io.File folder = new java.io.File(sketchPath("photos"));
  files= folder.listFiles();

  for (int i = 0; i <= files.length - 1; i++)
  {
    String path = files[i].getAbsolutePath();
    if (path.toLowerCase().endsWith(".jpg"))
    {
      //println(path.toLowerCase() + ".jpg", i);
    }
  }  
  println("Photocount: "+files.length);
  int rand = (int)random(0,files.length);
  String output = files[rand].getPath();
  println("Loading Random Image: "+output);
  return loadImage(output);
}

PImage loadExactPhoto(String path) {
  println("Loading Exactly: "+path);
  return loadImage(path);
}

String timeStamp() {
  String MM=str(month());
  String DD=str(day());
  String HH=str(hour());
  String M=str(minute());
  String SS=str(second());

  return (MM+DD+HH+M+SS);
}

void printFrame() {
    String url = "./temp/temp_"+timeStamp()+".png";
    saveFrame(url);
    PImage temp = loadImage(url);
    PGraphics pdf = createGraphics(720, 1080, PDF, "./print/print_"+timeStamp()+".pdf");
    
    //Draw Photo in Buffer
    pdf.beginDraw();
    
    pdf.background(255, 255, 255);
    pdf.stroke(0);
    pdf.image(temp,-600,0);
    
    pdf.dispose();
    pdf.endDraw();
    
    println("Saved PDF for Printing");
}

void printFrame_old() {
    saveFrame("./print/print_"+timeStamp()+".png");
}

void doTicks() {
if(tick==0)
  { counter[1]=false;
  }
  if(tick>6)
  {
   image(cam,0,0,1920,1080);
   image(profile,0,0,1920,1080);
   if(counter[3]==true)
   {
      fill(255);
      textSize(130);
      textAlign(CENTER);
      text("3", 960, 480);
   }
   if(counter[2]==true)
   {
      fill(255);
      textSize(130);
      textAlign(CENTER);
      text("2", 960, 480);
      counter[3]=false;
   }
   if(counter[1]==true)
   {
      fill(255);
      textSize(130);
      textAlign(CENTER);
      text("1", 960, 480);
      counter[3] = false;
      counter[2] = false;
   }
  }
}

void captureEvent(Capture c) {
  c.read();
}