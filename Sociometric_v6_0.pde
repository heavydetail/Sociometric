import processing.video.*;
import processing.pdf.*;
import diewald_bardcode.*;
import diewald_bardcode.CONSTANTS.*;
import controlP5.*;
import java.util.Date;
import processing.serial.*;
import processing.serial.Serial;
import com.dhchoi.CountdownTimer;
import com.dhchoi.CountdownTimerService;

//GLOBVARS
Scanner scan;
Capture cam;
Serial myPort;
Intro intro;
int translator;
CountdownTimer timer;
String timerCallbackInfo = "";
int tick=0;
boolean counter[] = {false,false,false,false};

//Settings
//Countdown
int time;
int wait=7000;
int trigger = 0;
int count = 14;
int myframeCountAtStart;
int toUseForTint;
int alpha = 1, delta = 1;

//IMG
PImage white, adjust, profile, barcodereading, drawing, standby, adder;

PFont font, bfont;

//GLOBAL SWITCHES:
boolean foundBarCode = false;
boolean infoShown = false;
//boolean infoShowing = false; //hm
boolean pictureTaken = false;
boolean countDowned = false;
boolean inCountDown = false;
String processurl = "";
int drawingTime = 20000;
int startTime = 0;
int startPhotoTime = 0;

void setup() {
	size(1920, 1080);
  //fullScreen(1);
  background(255);
  frameRate(30);
  
  //Connect Arduino
  try {
  String[] portName = Serial.list(); //change the 0 to a 1 or 2 etc. to match your port
  printArray(portName);
  myPort = new Serial(this, portName[0], 250000);
  
  } catch(Exception e) {
    //Handle Error if Arduino not connected
    println(e);
    e.printStackTrace();
  }
  
  //Images
  white = loadImage("./graphics/white-screen.png");
  adjust = loadImage("./graphics/adjust.png");
  profile = loadImage("./graphics/profile.png");
  barcodereading = loadImage("./graphics/barcode-reading.png");
  drawing = loadImage("./graphics/drawing.png");
  standby = loadImage("./graphics/stand-by-screen.png");
  adder = loadImage("./graphics/white-screen.png");

  //Font
  font = createFont("./fonts/LetterGothicStd.otf", 20);
  bfont = createFont("./fonts/LetterGothicStd-Bold.otf", 25);

  //Setup Intro drawing (implemented in Intro.pde)
  intro = new Intro();
  intro.setupIntro();
  
  smooth();
  noStroke();
  colorMode(RGB, 255, 255, 255, 100);
  imageMode(CORNER);
  
  String[] cameras = Capture.list();
  printArray(cameras);
  cam = new Capture(this, cameras[29]);
  cam.start();

	//start scanner thread (implement in Scanner.pde)
  scan = new Scanner();
  scan.start();
  
  startTime = millis();
}

void draw() {
  doTicks(); //Draw Webcam Image if needed and show Countdown Ticks
  
	//draw random intro face if not in process
  if((!infoShown && !foundBarCode && !countDowned && !inCountDown)) //||!intro.isIntro
  {
    int now = millis();
    if((now - startTime >= drawingTime)) // || startTime == 0  && intro.isIntro
    //Draw new random face if just started or if current is drawing over drawingTime
    {
      //New Random Drawing and Reset to Intro
      if(frameCount > 100)
        intro = intro; //Breakpoint Hack
      
      if(intro.isIntro)
      {
        fill(255);
        rect(0,0,1920,1080);
        
        intro = new Intro();
        intro.setupIntro();
        intro.isIntro = true;
        intro.sourcepath = "";
      } else {
        int nowPhotoTime = millis();
        if((nowPhotoTime - startPhotoTime >= drawingTime))
        {
          printFrame(); //<>//
          delay(10000);
          fill(255);
          rect(0,0,1920,1080);
          
          intro = new Intro();
          intro.setupIntro();
          intro.isIntro = true;
          intro.sourcepath = "";
          
          scan.sleeping = false;
          //startPhotoTime = millis();
        }
      }
      
      startTime = millis(); //save start time
    }
    
    intro.loop();
  }
  
  //When Barcode found, take picture.
  if(foundBarCode && !pictureTaken)
  { 
    scan.sleeping = true;
    
    if(!infoShown && !inCountDown)
      showInformation();
    
    if(infoShown && !countDowned && !pictureTaken && !inCountDown)
    { 
      startTimer();
    }
    
    if(infoShown && countDowned && !pictureTaken)
    {
       println("Taking Picture");
       processurl = takePicture();
       println("Saved as: "+processurl);
       fill(255);
       rect(0,0,1920,1080);
    }
  }
  
  if(foundBarCode && infoShown && countDowned && pictureTaken) {
      println("Resetting");
      //fill(255);
      //rect(0,0,1920,1080);
      foundBarCode = false; //Reset to scanning for BarCode
      
      //infoShowing = false;
      infoShown = false;
      inCountDown = false;
      countDowned = false;
      pictureTaken = false;
      
      if(processurl.equals(""))
      {
        intro = new Intro();
        intro.isIntro = true;
        intro.sourcepath = "";
        intro.setupIntro();
        scan.sleeping = false;
        
      } else {
        intro = new Intro();
        intro.isIntro = false;
        intro.sourcepath = processurl;
        intro.setupIntro();
        processurl="";
        scan.sleeping = true;
      }
    }
}