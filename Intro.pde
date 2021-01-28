class Intro {
  //Barcode Reader Values
  int health, credit, carreer, security;
  
  //Vars
  public String mUrl;
  PImage source; // Source image
  PImage temp;
  //for each "worm", variables: position
  
  public boolean isIntro = true; //Run as Intro or as Process Drawing
  public String sourcepath = "";
  
  //aimed direction
  PVector vise=new PVector();
  int locPixel;
  ArrayList <Seeker> seekersArray;
  float seekX,seekY;
  //worm's length
  int maxLength;
  int maxLayers;
  //like pixels[], to keep track of how many times a point is reached by a worm
  int [] buffer;
  int [] limiteDown;
  //number of worms at the beginning
  int nbePoints;
  public float inertia;
  //width and length of the drawing area
  int larg;
  int haut;
  int largI;
  int hautI;
  //brightness of the destination pixel
  float briMax;
  //minimum brightness threshold
  public int seuilBrillanceMini;
  //maximum brightness threshold
  public int seuilBrillanceMaxi;
  //location of the tested point in pixels[]
  int locTest;
  int locTaX;
  int locTaY;
  int brightnessTemp;
  //around a point (worms position), how many pixels will we look at...
  int amplitudeTest;
  //constrain the acceleration vector into a devMax radius circle
  float devMax;
  //constrain the speed vector into a vMax radius circle
  float vMax;
  //not used:random factor
  int hasard;
  //stroke's weight (slider) or radius of ellipse used for drawing
  public float myweight;
  //draw or not (button onOffButton)
  public boolean dessine;
  //different drawing options
  public int modeCouleur;
  //fill color
  int macouleur;
  boolean limite;
  
  void setupIntro() {
    //Set default values or scanned values
    health = 25;
    credit = 25;
    carreer = 25;
    security = 25;

    larg=largI=1920;
    haut=hautI=1080;
    colorMode(RGB, 255,255,255,100);
    limite=false;
    
    adder = loadImage("./graphics/white-screen.png"); //Reset white pic
    
    //Is it an Intro Random Drawing or a just taken Photo?
    if(isIntro && sourcepath.equals(""))
    {
      temp = loadRandomPhoto();
      adder.copy(temp, 0, 0, temp.width, temp.height, 220, 0, temp.width, temp.height);
      source = adder;
      //source = loadRandomPhoto();
    }
    else
    {
      temp = loadExactPhoto(sourcepath);
      adder.copy(temp, 0, 0, temp.width, temp.height, 601, 0, temp.width, temp.height);
      source = adder;
      startPhotoTime = millis();
    }
    println("Drawing Image "+sourcepath);
    
    if(hautI*source.width>largI*source.height){
      larg=largI;
      haut=larg*source.height/source.width;
    }else{
      haut=hautI;
      larg=haut*source.width/source.height;
    }
    source.resize(larg,haut);
    source.loadPixels();
    fill(0);
    initialiser();
  }
  
  //launched after setup and any time you hit the ResetButton button
  public void initialiser() {
    dessine=true;
    nbePoints=1;
    fill( 255 );
    stroke( 100 );
    //rect( 0, 0, larg+1000,haut+1000 );
    buffer=new int[haut*larg];
    smooth();
    inertia=3; //3
    maxLayers=3; //3
    myweight=1.2; //.4 Weigth
    seuilBrillanceMaxi=150; //200
    seuilBrillanceMini=130; //170
    amplitudeTest=3; //1 ??
    maxLength=2500; //500
    limite=true; //true
    hasard=20; //0 ??
    devMax=8; //5 Deviation
    vMax=50;//35 Tightness
    modeCouleur=2; //1 ??
    strokeJoin(ROUND);
    seekersArray=new ArrayList <Seeker>();
    
    for(int i=0;i<nbePoints;i++) {
    
    Seeker mSeeker=new Seeker(new PVector(random(larg),random(haut)),new PVector(random(-3,3),random(-3,3)),inertia);
    
    while((brightness(mSeeker.getImgPixel())>seuilBrillanceMaxi)||(brightness(mSeeker.getImgPixel())<seuilBrillanceMini))
    {
    mSeeker.setP(int(random(width)),int(random(height)));
    }
    seekersArray.add(mSeeker);
    }
  }
  
  void loop() {
    translator=0;
    //Draw Overlay Graphics if Intro
    if(isIntro)
    {
      image(standby, 0, 0, 1920, 1080);
      //translate to the left
      //translator=(int)(1200-source.width)/2; // / 2
      //translator=-350;
      translate(translator, 0);
      
    } else {
      //image(drawing, 0,0,1920,1080);
      //translate to the center
      //translator=(int)(1920-source.width)/2;
      //translator = 350;
      translate(translator, 0);
    }

    //println("Drawing Intro");
    if (dessine){//window.toggleOnOff) {
      for (int i = 0; i < nbePoints; i++) {
        Seeker mSeeker = seekersArray.get(i);
        dessin(mSeeker);
        
        if (mSeeker.isDeplace()) {
          mSeeker.setDeplace(false);
        }
      }
    }
    translate(-translator, 0);
  }
  
  void dessin(Seeker mSeeker) {
    
    // for each "seeker" (worm's head)
    // //on va tester les pixels autour du mobile p[t] en direction de la
    // vitesse du mobile
    // //calcul du barycentre des points testes ponderes de la brillance
    // (vise.x, vise.y)
    // //for each seeker, we gonna test pixels around the seeker's position
    // and calculate their barycenter, loaded by pixels values (0/255
    // dark/light);
    // barycenter's coordinates
    //myweight=window.inertia;
    vise.x = 0;
    vise.y = 0;
    // avoid looking for mSeeker.p.x for every pixels
    seekX = mSeeker.getP().x;
    seekY = mSeeker.getP().y;
    int pixelsPosition = floor(seekX) + floor(seekY) * larg;
    int locTestX = floor(seekX);
    int locTestY = floor(seekY);
    
    // barycenter calculation
    for (int i = -amplitudeTest; i < amplitudeTest + 1; i++) {// /rdessin
    for (int j = -amplitudeTest; j < amplitudeTest + 1; j++) {
    locTaX = locTestX + i;
    locTaY = locTestY + j;
    // does the point belongs to the source image?
    if ((locTaX > 0) && (locTaY > 0) && (locTaX < larg - 1) && (locTaY < haut - 1)) {
    brightnessTemp = int(brightness(source.pixels[locTaX + larg * locTaY]));
    vise.sub(new PVector(i * brightnessTemp, j * brightnessTemp));
    }
    }
    }
    // coeur du comportement de seeker:
    // core of the behaviour of the seeker (http://www.shiffman.net/ see
    // wanderer's code)
    
    vise.normalize();
    vise.mult(100f/mSeeker.inertia);
    mSeeker.getV().add(new PVector(vise.x,vise.y));
    PVector deviation = mSeeker.getV().get();
    deviation.normalize();
    deviation.mult(devMax);
    mSeeker.getV().normalize();
    mSeeker.getV().mult(vMax);
    mSeeker.getP().add(deviation);
    // ******************different cases that lead to move the seeker to
    // another random place**************
    // outside window
    // on compte les segments de chaque ver
    // worm's length is increased
    mSeeker.setLongueur(mSeeker.getLongueur() + 1);
    float positionBrightness=brightness(mSeeker.getImgPixel());
    //println(positionBrightness+" "+mSeeker.getP().x+" "+mSeeker.getP().y);
    //dessine=false;
    // si c'est trop long on demenage
    // seeker's moved if worm's too long
    if (mSeeker.getLongueur() > maxLength) {
    deplacePoint(mSeeker);
    }
    if ((mSeeker.getP().x < 1) || (mSeeker.getP().y < 1) || (mSeeker.getP().x > larg - 1) || (mSeeker.getP().y > haut - 1))// ||
    {
    mSeeker.setDeplace(true);
    deplacePoint(mSeeker);
    return;
    }
    // buffer est une copie vide de l'image. on l'augmente pour chaque point
    // parcouru
    // buffer is an empty copy of the source image. It's increased every
    // time a point is reached.
    buffer[pixelsPosition]++;
    // si on est passe plus de n fois on demenage le point
    // If a point is reached n times, seeker is moved
    if (buffer[pixelsPosition] > maxLayers) {
    deplacePoint(mSeeker);
    }
    
    // inside window, limite on and inside value range
    if ((limite) && (positionBrightness <= seuilBrillanceMaxi) && (positionBrightness >= seuilBrillanceMini)) {
    if (mSeeker.getLimiteDown() != 0) {
    mSeeker.setLimiteDown(mSeeker.getLimiteDown() - 1);
    }
    }
    // limite on and outside value range
    if ((limite) && ((positionBrightness > seuilBrillanceMaxi) || (positionBrightness < seuilBrillanceMini))) {
    if (mSeeker.getLimiteDown() == 0) {
    mSeeker.setLimiteDown(2);
    }
    mSeeker.setLimiteDown(mSeeker.getLimiteDown() + 1);// print(mSeeker.limiteDown+" ");
    if (mSeeker.getLimiteDown() >= 140 / myweight) {
    mSeeker.setLimiteDown(0);
    deplacePoint(mSeeker);
    }
    }
    // null deviation
    if ((deviation.x == 0) && (deviation.y == 0)) {
    mSeeker.setLimiteDown(0);
    deplacePoint(mSeeker);
    }
    else briMax = brightness(source.pixels[pixelsPosition]);
    
    // go draw the seeker's shape
    mSeeker.setDia((float) (myweight));
    // * (1 - cos((mSeeker.getLongueur()) * PI * 2 / (float) maxLength)))
    mSeeker.setAlpha((max(0, (round(127 * mSeeker.getDia() / myweight) - (int) briMax / 2))));
    
    
     
    
    strokeWeight(mSeeker.getDia());
    line(seekX,seekY,mSeeker.getP().x,mSeeker.getP().y);
    //println("Size "+mSeeker.getDia());
    // on cree un nouveau vers de temps en temps (on pourrait tester selon
    // la brilance de la zone...)
    // from times to times a new worm is created
    
    
            
    
    if (random(1) > 1 - (255 - briMax) / (500 * seekersArray.size())) {
    seekersArray.add(new Seeker(new PVector(seekX, seekY), new PVector(mSeeker.getV().x * random(-3,3), mSeeker.getV().x * random(-3,3)), inertia));
    nbePoints++;
    // Log.d("DrawingView","Size "+seekersArray.size());
    }
    
    //***********color change*****************
    
    if ((seekX<(width/2))) {
      if((seekY<(height/2))) {
        stroke(241,125,128,mSeeker.getAlpha()); }
          else {
            stroke(115,116,149,mSeeker.getAlpha()); } }
      
     else if ((seekY<(height/2))) {
        stroke(104,168,173,mSeeker.getAlpha()); }
          else {
            stroke(196,212,143,mSeeker.getAlpha()); } 
            
  }
  
  // *****************move the seeker function***************************
  void deplacePoint(Seeker seeker) {
    seeker.setLongueur(0);
    seeker.setP(random(1, width - 1), random(1, height - 1));
    while ((brightness(seeker.getImgPixel()) > seuilBrillanceMaxi) || (brightness(seeker.getImgPixel()) < seuilBrillanceMini)) {
    seeker.setP(random(1, larg - 1), random(1, haut - 1));
    }
    seekX = seeker.getP().x;
    seekY = seeker.getP().y;
  }
  
  public void setDevMax(float devMax) {
    this.devMax = devMax;
  }
  
  public class Seeker {
    
    // position
    private PVector p = new PVector();
    // speed
    private PVector v = new PVector();
    private int imgPixel;
    private float inertia;
    // worm's length
    private float longueur;
    // worm's limite
    private int limiteDown;
    private int couleur;
    private int red = int(random(0, 100));
    // stroke weight
    private float dia;
    private boolean deplace;
    private int alpha;
    private float greenfade = random(1);
    private float bluefade = random(1);
    private float redfade = random(1);
    private float vegRatio = random(.25, 1);
    
    // Constructor
    public Seeker(PVector P, PVector V, float Inertia) {
    p = P;
    v = V;
    limiteDown = 0;
    longueur = 0;
    setInertia(random(-2, 2) + Inertia);
    setDeplace(false);
    }
    
    public int updateCouleur() {
    
    float green = green(couleur);
    float blue = blue(couleur);
    // if (view.getStyle() == DrawingView.STYLE_VEGETAL) {
    // if ((green > 150) || (green < 1))
    // greenfade = -greenfade;
    // green += greenfade;
    // if ((blue > 50) || (blue < 1))
    // bluefade = -bluefade;
    // blue += bluefade;
    // if ((red > 50) || (red < 1))
    // redfade = -redfade;
    // red += redfade;
    // couleur = Color.argb(alpha, red, green, blue);
    // } else if (view.getStyle() == DrawingView.STYLE_NORMAL) {
    if ((green > 100) || (green < 1))
    greenfade = -greenfade;
    green += greenfade;
    if ((blue > 100) || (blue < 1))
    bluefade = -bluefade;
    blue += bluefade;
    couleur =color(alpha, red, green, blue);
    // }
    // else if (view.getStyle() == DrawingView.STYLE_NEGATIF) {
    // couleur = Color.WHITE;
    // }
    return couleur;
    }
    
    public float getLongueur() {
    return longueur;
    }
    
    public void setLongueur(float longueur) {
    this.longueur = longueur;
    }
    
    public PVector getP() {
    return p;
    }
    
    public void setP(PVector p) {
    this.p = p;
    }
    
    public void setP(float a, float b) {
    this.p.x = a;
    this.p.y = b;
    }
    
    public PVector getV() {
    return v;
    }
    
    public void setV(PVector v) {
    this.v = v;
    }
    
    public void setV(float a, float b) {
    this.v.x = a;
    this.v.y = b;
    }
    
    public int getLimiteDown() {
    return limiteDown;
    }
    
    public void setLimiteDown(int limiteDown) {
    this.limiteDown = limiteDown;
    }
    
    public boolean isDeplace() {
    return deplace;
    }
    
    public void setDeplace(boolean deplace) {
    this.deplace = deplace;
    }
    
    public float getDia() {
    return dia;
    }
    
    public void setDia(float dia) {
    this.dia = dia;
    }
    
    public int getAlpha() {
    return alpha;
    }
    
    public void setAlpha(int alpha) {
    this.alpha = alpha;
    }
    
    public float getInertia() {
    return inertia;
    }
    public void setInertia(float inertia) {
    this.inertia = inertia;
    }
    
    
    public int getCouleur() {
    return couleur;
    }
    
    public void setCouleur(int couleur) {
    this.couleur = couleur;
    }
    
    public float getVegRatio() {
    return vegRatio;
    }
    
    public void setVegRatio(float vegRatio) {
    this.vegRatio = vegRatio;
    }
    public int getImgPixel(){
    if(getP().x>0 && getP().x<larg &&getP().y>0 && getP().y<haut)
    return source.pixels[floor(getP().x)+floor(getP().y)*larg];
    else{
    //println("Out of range");
    return 0;
    }
    }
  }
}