import java.util.Properties;
import geomerative.*;
import shapes3d.utils.*;
import shapes3d.animation.*;
import shapes3d.*;

Properties props;
int delay = 100;
PGraphics graphics;

Extrusion e;
Path path;
Contour contour;
ContourScale conScale;

Properties loadCommandLine () {

  Properties props = new Properties();
  if (args != null) {
    boolean quoted = false;
    String currArg = null;
    for (String arg : args) {
      if (quoted){
        if (arg.indexOf("\"") == arg.length() - 1){
          arg = arg.substring(0, arg.length() - 1);
          quoted = false;
        }
        props.setProperty(currArg, props.getProperty(currArg) + " " + arg);
      } else {
        String[] parsed = arg.split("=", 2);
        if (parsed.length == 2){
          if (parsed[1].indexOf("\"") == 0){
            quoted = true;
            currArg = parsed[0];
            parsed[1] = parsed[1].substring(1, parsed[1].length());
          }
          props.setProperty(parsed[0], parsed[1]);
        }
      }
    }
  }

  return props;
}

void setup(){
  size(100, 100, P2D);
  noLoop();
  
  //load arguments into Map
  props = loadCommandLine();
  
  //create appropriately-sized canvas
  graphics = createGraphics(
    parseInt(props.getProperty("width", "400")), 
    parseInt(props.getProperty("height", "200")),
    P3D);
  
  // VERY IMPORTANT: Allways initialize geomerative in the setup
  RG.init(this);
  
  // The vertices to be used for the Bezier spline
  PVector[] knots = new PVector[] {
    new PVector(240, 0, 50), 
    new PVector(120, 0, 0), 
    new PVector(0, 0, -100), 
    new PVector(-80, 0, 0), 
    new PVector(-40, 50, 0), 
    new PVector(60, 80, 50),
  };

  // Use a BezierSpline to define the extrusion path
  path = new P_BezierSpline(knots);
}

void draw(){
  RShape sText = RG.getText(props.getProperty("text", "some test"), "FreeSans.ttf", 72, CENTER);
  RG.setPolygonizer(RG.ADAPTATIVE);
  RPoint[] pText = sText.getPoints();
  RMesh mText = sText.toMesh();
  graphics.beginDraw();
  graphics.background(255);
  graphics.fill(0);
  graphics.stroke(0);
  graphics.text(props.getProperty("text", "some test"), 10, 20);
  graphics.translate(graphics.width/2, 100);
  sText.draw(graphics);
  graphics.translate(0, 50);
  for(int i = 0; i < pText.length; i++){
    graphics.point(pText[i].x, pText[i].y);
  }
  graphics.translate(0, 50);
  graphics.sphere(10);
  //mText.setFill(0);
  //mText.draw(graphics);
  graphics.endDraw();
  graphics.save(props.getProperty("image", "testImage.png"));
  exit();
}