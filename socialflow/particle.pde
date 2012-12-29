// a basic noise-based moving particle courtesy Amnon Owed
// Modified this a little to reduce randomness, make them slower and appear a little different
// Ankit Daftery 29 Dec 2012

class Particle {
  // unique id, (previous) position, speed
  float id, x, y, xp, yp, s, d;
  color col; // color
  
  Particle(float id) {
    this.id = id;
    s = random(2, 3); // speed
  }
  
  void updateAndDisplay() {
    // let it flow, end with a new x and y position
    id += 0.01;
    d = (noise(id, x/globalY, y/globalY)-0.5)*globalX;
    x += cos(radians(d))*0.2;
    y += sin(radians(d))*0.2;

    // constrain to boundaries
    if (x<-10) x=xp=kinectWidth+10;
    if (x>kinectWidth+10) x=xp=-10;
    if (y<-10) y=yp=kinectHeight+10;
    if (y>kinectHeight+10) y=yp=-10;

    // if there is a polygon (more than 0 points)
    if (poly.npoints > 0) {
      // if this particle is outside the polygon
      if (!poly.contains(x, y)) {
        // while it is outside the polygon
        while(!poly.contains(x, y)) {
          // randomize x and y
          x = random(kinectWidth);
          y = random(kinectHeight);
        };
        // set previous x and y, to this x and y
        xp=x;
        yp=y;
      }
    }
    
    // individual particle color
    stroke(col);
    strokeWeight(2);
    // Draw a point where the particle is. I used a point instead of a line because I wanted less randomness. 
    point(xp,yp);
    // line from previous to current position
    //line(xp, yp, x, y);
    
    // set previous to current position
      xp=x;
      yp=y;
  }
}
