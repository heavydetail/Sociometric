//Take Photo Countdown etc.
String takePicture()
{
  image(cam,0,0,1920,1080);
  
  PImage partialSave = get(600, 0, 720, 1080);
  String url = "./photos/photo_" + timeStamp() + ".jpg";
  partialSave.save(url);

  pictureTaken = true;
  return url;
}

void showInformation()
{
    image(cam, 0, 0, 1920, 1080);
    image(barcodereading, 0, 0, 1920, 1080);
    
    //if(tick<13) { 
    int x_pos = 960;
    int y_pos = 440;
    
    fill(0); 
    textAlign(CENTER, TOP);
    textFont(bfont);
    textSize(20);
    text("Your barcode has been read", x_pos, y_pos);   

    y_pos += 60;
    x_pos += 160;

    fill(104, 168, 173);
    textFont(bfont);
    textSize(20);
    textAlign(RIGHT, TOP);
    text("health insurance risk: [ %" + scan.health + " ]", x_pos, y_pos);

    y_pos += 40;
    fill(196, 212, 143);
    textFont(bfont);
    textSize(20);
    textAlign(RIGHT, TOP);
    text("credit related risk: [ %" + scan.credit + " ]", x_pos, y_pos);

    y_pos += 40;
    fill(115, 116, 149);
    textFont(bfont);
    textSize(20);
    textAlign(RIGHT, TOP);
    text("career related risk: [ %" + scan.carreer + " ]", x_pos, y_pos);

    y_pos += 40;
    fill(241, 125, 128);
    textFont(bfont);
    textSize(20);
    textAlign(RIGHT, TOP);
    text("personal security risk: [ %" + scan.security + " ]", x_pos, y_pos);
    
    //delay(wait);
    //infoShowing = true;
    infoShown = true;
   //}
    
}

void startTimer() {
  timer = CountdownTimerService.getNewCountdownTimer(this).configure(1000, 20000).start();
  inCountDown=true;
}

void onTickEvent(CountdownTimer t, long timeLeftUntilFinish) {
  timerCallbackInfo = "[tick] - timeLeft: " + timeLeftUntilFinish + "ms";
  tick++;
  
  println("Tick: "+tick);
  
  if(tick==16)
  {
    try { myPort.write('3'); } catch(Exception e) { println("Flash: Arduino not found."); }
    println("Flash #3");
    counter[3]=true;
  }
  if(tick==17)
  {
    try { myPort.write('2'); } catch(Exception e) { println("Flash: Arduino not found."); }
    println("Flash #2");   
    counter[2]=true;
  }
  if(tick==18)
  {
    try { myPort.write('1'); } catch(Exception e) { println("Flash: Arduino not found."); }
    println("Flash #1");   
    counter[1]=true;
  }
}

void onFinishEvent(CountdownTimer t) {
  timerCallbackInfo = "[finished]";
  println("Countdowned");
  try { myPort.write('0'); } catch(Exception e) { println("Flash: Arduino not found."); }
  
  //RESET
  tick=0;
  inCountDown = false;
  countDowned = true;
  timer.stop();
}