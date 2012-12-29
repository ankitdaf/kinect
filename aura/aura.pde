// Kinect Body Outline Example 
// Modified by Ankit Daftery 29/12/12

// import libraries

// The graphic libraries
import processing.opengl.*; // opengl
import javax.media.opengl.*;
import java.awt.Polygon;  // this is a regular java import so we can use and extend the polygon class (see PolygonBlob)
import java.awt.Graphics2D; 
import controlP5.*; // For visual controls
import toxi.geom.*; // toxiclibs shapes and vectors
import toxi.processing.*; // toxiclibs display

// The Image processing libraries
import SimpleOpenNI.*; // kinect
import blobDetection.*; // blobs

// Other Java Imports

import java.net.*;
import java.util.Collections; // For collections in Processing 2.0b7
import java.awt.image.BufferedImage;
import java.util.Timer;
import java.util.TimerTask;
import java.io.*;
import javax.imageio.*;

// Initiate the global objects used from the libraries

ControlP5 cp5;  // Visual control panel
PGraphicsOpenGL pgl;
GL gl; 
SimpleOpenNI kinect;  // declare SimpleOpenNI object
BlobDetection theBlobDetection;  // declare BlobDetection object
PolygonBlob poly = new PolygonBlob();  // declare custom PolygonBlob object (see class for more info)
ToxiclibsSupport gfx; // ToxiclibsSupport for displaying polygons

// Global variables
PImage dispImg; // For manipulation of the screen for the glowy effect
PImage cam,blobs;  // PImage to hold incoming imagery for blob detection
int kinectWidth = 640;  // the kinect's dimensions to be used later on for calculations
int kinectHeight = 480;
float reScale;  // to center and rescale from 640x480 to higher custom resolutions
int nou_old=0;  //old number of users to keep track, since the Kinect is being a royal pain in the arse
int[] screenBuf;  // To be used for for a shiftBlur
color bgColor;  // background color
PImage bgImg; // Background Image
Boolean canUpload=true;   // To keep track of Posting to Facebook so we don't flood 
Particle[] flow = new Particle[3500];  // an array to hold 3500 Particle objects to begin with
float globalX, globalY;  // global variables to influence the movement of all particles
PGraphics bufimg;
int[] blobpixels; // For copying the processed pixels into the blob image
color[] colorPalette;


String[] palettes = {
  "-1117720,-13683658,-8410437,-9998215,-1849945,-5517090,-4250587,-14178341,-5804972,-3498634", 
  "-67879,-9633503,-8858441,-144382,-4996094,-16604779,-588031", 
  "-16711663,-13888933,-9029017,-5213092,-1787063,-11375744,-2167516,-15713402,-5389468,-2064585"
};          // three color palettes courtest Amnon Owed


int[] user1;

void setup() {
  size(1600, 900, P2D);  // setup size and graphics mode, I am using P3D
  cp5 = new ControlP5(this);
  PImage[] imgs = {loadImage("facebook.png"),loadImage("facebook.png"),loadImage("facebook.png")};  // Images for the button in different states
  cp5.addButton("Facebook")   // adding the facebook share button
    .setValue(128)
    .setPosition(width-150,0)
    .setImages(imgs)
    .updateSize()
    ;
  kinect = new SimpleOpenNI(this);  // initialize SimpleOpenNI object
  if (!kinect.enableScene()) {  // Check to see if the Kinect is available, quit otherwise
    println("No scene image");
    exit();
  }
  else {
    setupKinect(kinect);  // Setup parameters for the kinect
    reScale = (float) width / kinectWidth;  // calculate the reScale value
    blobs = createImage(kinectWidth/3, kinectHeight/3, RGB);  // create a smaller blob image for speed and efficiency
    theBlobDetection = new BlobDetection(blobs.width, blobs.height);  // initialize blob detection object to the blob image dimensions
    theBlobDetection.setThreshold(0.3f);  // A threshold of 0.2 or 0.3 is best, I don't know why
    dispImg = createImage(1600,900,RGB);
    gfx = new ToxiclibsSupport(this); // initialize ToxiclibsSupport object
  }
}

void draw() {
  blendMode(REPLACE); // Replace the previous image, we have new things to draw
  image(bgImg,0,0); // Giving our effect a background to match
  kinect.update();  // Get fresh information from the Kinect
  cam = kinect.sceneImage().get();  // Get information from the scene
  background(0);  
  IntVector userList = new IntVector();
  int nou = kinect.getNumberOfUsers();
  if (nou < nou_old) nou_old = nou;
  if (nou_old>0) {
    {
      user1 = kinect.getUsersPixels(SimpleOpenNI.USERS_ALL);    // find out which pixels have users in them
      blobs.pixels = user1 ;    // clean up blobs.pixels
      for (int   i = 0; i < user1.length; i++) {    // populate the pixels array from the sketch's current contents
        if (user1[i] != 0) {    // if the current pixel is on a user
          blobs.pixels[i] = 255;  // make it white and distinguishable 
        }
        else
        {
          blobs.pixels[i] = 0;
        }
      }

      theBlobDetection.computeBlobs(blobs.pixels);
      poly = new PolygonBlob();         // initialize a new polygon
      poly.createPolygon();         // create the polygon from the blobs (custom functionality, see class)
      polyglow(gfx, poly);    // Shine, baby !
    }
  }
}

// Helper method to initialize the P2D layer to glow mode thanks to flight404

void setupgl()
{
  pgl = (PGraphicsOpenGL) g;
  GL gl = pgl.beginPGL().gl;  // JOGL's GL object
  gl.glDisable(GL.GL_DEPTH_TEST);  // This fixes the overlap issue
  gl.glEnable(GL.GL_BLEND);  // Turn on the blend mode
  gl.glBlendFunc(GL.GL_SRC_ALPHA,GL.GL_ONE);  // Define the blend mode
  gl.glClear(GL.GL_DEPTH_BUFFER_BIT);
}

// A function to easily setup features required from the Kinect OpenNI interface

void setupKinect(SimpleOpenNI kinect)
{
  kinect.setMirror(true);  // mirror the image to make the display more intuitive
  kinect.enableUser(SimpleOpenNI.SKEL_PROFILE_NONE);  // We need to enable user tracking but do not use skeleton joints here
  kinect.enableGesture(); // Enable Gesture tracking to be used to find the hand the first time
  kinect.enableHands();   // Enable hand tracking to be used for "Share on Facebook" feature
  kinect.addGesture("RaiseHand");  // Tell the kinect that we would like it to report a Raised Hand gesture
}


// An experiment to make a body "glow"
void polyglow(ToxiclibsSupport gfx, PolygonBlob poly)
{
  noFill();
  tint(255, 255);
  strokeWeight(10);
  stroke(250, 250, 52);
  scale(reScale);
  gfx.polygon2D(poly);
  blendMode(ADD);
  dispimg = get();
  scale(1/reScale);
  dispimg.resize(1600/4, 0);
  dispimg.filter(BLUR, 2);
  dispimg.resize(1600, 0);
  tint(255, 180);
  image(dispimg,0,0);
}

// SimpleOpenNI callback method when the Kinect "loses" a user

void onLostUser(int userId)
{
  println("Lost the user " + userId);
  kinect.stopTrackingSkeleton(userId);
  if(nou_old>0) nou_old -=1;    // Shouldn't be needing this but there do seem to be some glitches, so necessary not to kill people unnecessarily
  println("Number of users " + nou_old);
}

// SimpleOpenNI callback method when the Kinect finds a user it was tracking is gone for more than 10 seconds, counts as an exit

void onExitUser(int userId)
{
  println("User exit " + userId);
  kinect.stopTrackingSkeleton(userId);  // Stop reminiscing, it hurts
  if(nou_old>0) nou_old -= 1;
  print("Number of users " + nou_old);
}

// SimpleOpenNI callback method when the Kinect finds a new user

void onNewUser(int userId) {
  println("start pose detection for" + userId);
  nou_old += 1;   // We have a newcomer in our midst
  println("Number of users " + nou_old);
//kinect.requestCalibrationSkeleton(userId,true); // Still unable to decide whether this is necessary to make tracking more reliable
}


// -----------------------------------------------------------------
// hand events 5

void onCreateHands(int handId, PVector position, float time) {
  kinect.convertRealWorldToProjective(position, position);
  println("Found hands");
}

void onUpdateHands(int handId, PVector position, float time) {
PVector p = new PVector();
if(position.x>kinectWidth*0.8 && position.y>0.75*kinectHeight) 
{
  if(canUpload)   // Wouldn't want to flood Facebook with another post when this one hasn't gone through, would we ?
  {
  canUpload = false;
  println("Clicking");
  new Poster(4);
  }
}
}oh wait, i'll ju

void onDestroyHands(int handId, float time) {
  kinect.addGesture("RaiseHand");
}

// -----------------------------------------------------------------
// gesture events 6
void onRecognizeGesture(String strGesture,PVector idPosition,PVector endPosition)
{
  println("Recognized Gesture");
  kinect.startTrackingHands(endPosition);
  kinect.removeGesture("RaiseHand");
}

// A method to post the image to your own server. Thanks a ton to philho for this
// Use this method to post the image to your own server. You can then use a script there to store, manipulate and post images to Facebook, twitter etc

void post(Timer tim)
{
  DataUpload du = new DataUpload();
  boolean bOK = false;
  // Upload the currently displayed image with a fixed name, and the chosen format
  // We need a new buffered image without the alpha channel
  BufferedImage imageNoAlpha = new BufferedImage(width, height, BufferedImage.TYPE_INT_RGB);
  loadPixels();
  imageNoAlpha.setRGB(0, 0, width, height, g.pixels, 0, width);
  //  Ideally shouldn't be needing this section but something I have done posts all the images inverted, so flipping them back
  BufferedImage dimg = new BufferedImage(width,height,imageNoAlpha.getColorModel().getTransparency());
  Graphics2D g2 = dimg.createGraphics();
  g2.drawImage(imageNoAlpha,0,0,width,height,0,height,width,0,null);
  g2.dispose();
  // end of inversion section
  bOK = du.UploadImage("snapshot.jpeg", dimg);
  if (!bOK)
      return; // Some problem on Java side. Do nothing

    // Get the answer of the PHP script
    int rc = du.GetResponseCode();
    String feedback = du.GetServerFeedback();
    println("----- " + rc + " -----\n" + feedback + "---------------");
  // A flash of white light, like that at the moment of creation. Of a snapshot.
    fill(255);
    rect(0,0,width,height);
    tim.cancel(); // Cancel the timer, we are done with it
}

// A class to handle posting data to a web server

public class Poster{
  Timer tim;
  
  public Poster(int seconds)
  {
    tim = new Timer();
    tim.schedule(new PostTask(),seconds*1000);
  }
  class PostTask extends TimerTask {

    public void run() {
      println("Time's up!");
      post(tim);  // Passing the timer as a parameter to cancel the timer in the posting method. Was getting system crashes otherwise
      canUpload = true; // Re-enable upload, we just posted one
      }
  }
}