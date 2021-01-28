/////////////////
//SCANNER THREAD:

class Scanner extends Thread
{ 
  boolean quitter;
  boolean running;
  boolean sleeping;
  
  int count;
  int prevTime = millis(); //Store when Thread was created.
  float fr = 1000;    //Framerate of the separate thread, the higher, the more artifacts
  boolean limitedFramerate = true;
  
  //Decoding
  int health, credit, carreer, security; //Risk Percentages
  String barcode;
  boolean readSuccess;
  
  //Constructor:
  Scanner() 
  {
    //init shit:
    running = false;
    quitter=false;
    readSuccess=false;
    sleeping=false;
    count = 0;
  }

  void start()
  {
    running = true;
    super.start();
  }

  void run()
    {
        while (running)
        {
          if(!sleeping)
          {
          //TIMING SHIT:
          boolean runIt = false;

          if(limitedFramerate)
          {
            if(millis() - prevTime > 1000.0/fr) runIt = true;
          }
          else runIt = true;  
    
          if (runIt)
          {
              count++;
              try
              {  
                 //READ BARCODE
                 if(cam.available())
                 {
                   cam.read();
                   //barcode-reading values
                   DecodingResult dr = Barcode.decode(cam, CHARACTER_SET.DEFAULT, true, DECODE.EAN_13);
                   if(!dr.decodingFailed())
                   {
                     barcode = dr.getText();
                     
                     println("barcode=" + barcode);
                     calculatePercentages(barcode);
                     
                     readSuccess = true;
                   }
                 }
                 
                 if(readSuccess)
                 {
                    foundBarCode=true;
                    readSuccess = false;
                 }
              }
              catch(Exception e)
              {
                //Handle Errors:
                println(e);
                e.printStackTrace();
              }
              prevTime = millis();
            }
          }
        }
    }
   
   void quit()
   {
      running = false;
      interrupt();
   }
   
   void calculatePercentages(String _bc)
   {
      int he = Integer.parseInt(_bc.substring(1, 4));
      //println("health-uncalculated=" + he);
      int cre = Integer.parseInt(_bc.substring(4, 7));
      //println("credit-uncalculated=" + cre);
      int car = Integer.parseInt(_bc.substring(7, 10));
      //println("career-uncalculated=" + car);
      int se = Integer.parseInt(_bc.substring(10, 13));
      //println("security-uncalculated=" + se);
      
      if (he > 200) {
        health = (he % 200) * (-1);
      } else {
        health = he;
      }
      println("health=" + health );

      if (cre > 200) {
        credit = (cre % 200) * (-1);
      } else {
        credit = cre;
      }
      println("credit=" + credit );

      if (car > 200) {
        carreer = (car % 200) * (-1);
      } else {
        carreer = car;
      }
      println("career=" + carreer);

      if (se > 200) {
        security = (se % 200) * (-1);
      } else {
        security = se;
      }
      println("security=" + security );
   }
}