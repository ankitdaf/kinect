// an extended polygon class quite similar to the earlier PolygonBlob class (but extending Toxiclibs' Polygon2D class instead)
// Courtesy Amnon Owed

class PolygonBlob extends Polygon2D {
  // the createPolygon() method is nearly identical to the one presented earlier
  // see the Kinect Flow Example for a more detailed description of this method (again, feel free to improve it)
  void createPolygon() {
    ArrayList<ArrayList<PVector>> contours = new ArrayList<ArrayList<PVector>>();
    int selectedContour = 0;
    int selectedPoint = 0;

    // create contours from blobs
    for (int n=0 ; n<theBlobDetection.getBlobNb(); n++) {
      Blob b = theBlobDetection.getBlob(n);
      if (b != null && b.getEdgeNb() > 100) {
        ArrayList<PVector> contour = new ArrayList<PVector>();
        for (int m=0; m<b.getEdgeNb(); m++) {
          EdgeVertex eA = b.getEdgeVertexA(m);
          EdgeVertex eB = b.getEdgeVertexB(m);
          if (eA != null && eB != null) {
            EdgeVertex fn = b.getEdgeVertexA((m+1) % b.getEdgeNb());
            EdgeVertex fp = b.getEdgeVertexA((max(0, m-1)));
            float dn = dist(eA.x*kinectWidth, eA.y*kinectHeight, fn.x*kinectWidth, fn.y*kinectHeight);
            float dp = dist(eA.x*kinectWidth, eA.y*kinectHeight, fp.x*kinectWidth, fp.y*kinectHeight);
            if (dn > 15 || dp > 15) {
              if (contour.size() > 0) {
                contour.add(new PVector(eB.x*kinectWidth, eB.y*kinectHeight));
                contours.add(contour);
                contour = new ArrayList<PVector>();
              } else {
                contour.add(new PVector(eA.x*kinectWidth, eA.y*kinectHeight));
              }
            } else {
              contour.add(new PVector(eA.x*kinectWidth, eA.y*kinectHeight));
            }
          }
        }
      }
    }
    
    while (contours.size() > 0) {
      
      // find next contour
      float distance = 999999999;
      if (getNumPoints() > 0) {
        Vec2D vecLastPoint = vertices.get(getNumPoints()-1);
        PVector lastPoint = new PVector(vecLastPoint.x, vecLastPoint.y);
        for (int i=0; i<contours.size(); i++) {
          ArrayList<PVector> c = contours.get(i);
          PVector fp = c.get(0);
          PVector lp = c.get(c.size()-1);
          if (fp.dist(lastPoint) < distance) { 
            distance = fp.dist(lastPoint); 
            selectedContour = i; 
            selectedPoint = 0;
          }
          if (lp.dist(lastPoint) < distance) { 
            distance = lp.dist(lastPoint); 
            selectedContour = i; 
            selectedPoint = 1;
          }
        }
      } else {
        PVector closestPoint = new PVector(width, height);
        for (int i=0; i<contours.size(); i++) {
          ArrayList<PVector> c = contours.get(i);
          PVector fp = c.get(0);
          PVector lp = c.get(c.size()-1);
          if (fp.y > kinectHeight-5 && fp.x < closestPoint.x) { 
            closestPoint = fp; 
            selectedContour = i; 
            selectedPoint = 0;
          }
          if (lp.y > kinectHeight-5 && lp.x < closestPoint.y) { 
            closestPoint = lp; 
            selectedContour = i; 
            selectedPoint = 1;
          }
        }
      }

      // add contour to polygon
      ArrayList<PVector> contour = contours.get(selectedContour);
      if (selectedPoint > 0) { Collections.reverse(contour); }
      for (PVector p : contour) {
        add(new Vec2D(p.x, p.y));
      }
      contours.remove(selectedContour);
    }
  }
  
 // ==================================================
// drawBlobsAndEdges() from the Processing forums
// ==================================================
void drawBlobsAndEdges(boolean drawBlobs, boolean drawEdges)
{
  noFill();
  Blob b;
  EdgeVertex eA,eB;

  int iPolyCount=0;

  for (int n=0 ; n<theBlobDetection.getBlobNb() ; n++)
  {
    //choose voice
    iPolyCount++;
    b=theBlobDetection.getBlob(n);
    if (b!=null)
    {
      // Edges
      if (drawEdges)
      {
        strokeWeight(3);
        stroke(0,255,0);
        for (int m=0;m<b.getEdgeNb();m++)
        {
          eA = b.getEdgeVertexA(m);
          eB = b.getEdgeVertexB(m);
          if (eA !=null && eB !=null)
          //glow(eA,eB);
            line(eA.x*width, eA.y*height,eB.x*width, eB.y*height);                                          
        }
      }

      // Blobs
      if (drawBlobs)
      {
        strokeWeight(1);
        stroke(0,255,0);
        rect(
        b.xMin*width,b.yMin*height,
        b.w*width,b.h*height
          );

      }

    }

  }
}
}
