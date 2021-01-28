/*int countStartTime;
int act;

void countDownMS() {
  cam.read();
  image(cam, 0, 0, 1920, 1080);
  
  int now = millis();
  int took = now - countStartTime;
  int secs = (int)took / 1000;
  
  if(act == count) {
    countStartTime = millis();
    inCountDown = true;
  }
  
  if(secs > 6)
  {
    
  }
  
  if(secs == 3)
  {
    try { myPort.write('3'); } catch(Exception e) { println("Flash: Arduino not found."); }
    println("Flash #3");
  }
  
  if(secs == 2)
  {
    try { myPort.write('2'); } catch(Exception e) { println("Flash: Arduino not found."); }
    println("Flash #2");
  }
  
  if(secs == 1)
  {
    try { myPort.write('1'); } catch(Exception e) { println("Flash: Arduino not found."); }
    println("Flash #1");
  }
  
}

//OLD COUNTDOWN METHOD
void countDown() {
    //image(cam, 0, 0, 1920, 1080);
  
    if (count > 0) {
        inCountDown = true;
        count --;
        println("#"+count);
        delay(1000);

        if(count <= 8) {
          
          cam.read();
          image(cam, 0, 0, 1920, 1080);
          image(profile, 0, 0, 1920, 1080);
          /*
          if (alpha == 0 || alpha == 255) { 
            delta = -delta;
          }
          
          alpha += delta;
          fill(255, 255, 255, alpha);
          rect(0, 0, 1920, 1080);
          *
          
          if(count >= 0 && count < 8) {
            delay(1000);
            
            if (count == 3) {
              try { myPort.write('3'); } catch(Exception e) { println("Flash: Arduino not found."); }
              println("Flash #3");
            }
            if (count == 2) {
              try { myPort.write('2'); } catch(Exception e) { println("Flash: Arduino not found."); }
              println("Flash #2");
            }
            if (count == 1) {
              try { myPort.write('1'); } catch(Exception e) { println("Flash: Arduino not found."); }
              println("Flash #1");
            }
            
            fill(255);
            textSize(130);
            textAlign(CENTER);
            text(count, 960, 480);

          }
        }
      }
      
      if (count == 0) {
              println("Countdowned");
              try { myPort.write('0'); } catch(Exception e) { println("Flash: Arduino not found."); }
              countDowned = true;
              count = 14;
              inCountDown = false;
      }
}*/