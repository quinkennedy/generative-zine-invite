import java.util.Properties;
import geomerative.*;

Properties props;
boolean hasProps = false;
PGraphics graphics;
int iteration = 0;

Properties loadCommandLine () {

  Properties props = new Properties();
  if (args != null) {
    hasProps = true;
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
            if (parsed[1].indexOf("\"") == parsed[1].length() - 1){
              parsed[1] = parsed[1].substring(0, parsed[1].length() - 1);
              quoted = false;
            }
          }
          props.setProperty(parsed[0], parsed[1]);
        }
      }
    }
  }

  return props;
}

void setup(){
  size(600, 600, P3D);
  //noLoop();
  
  //load arguments into Map
  props = loadCommandLine();
  
  //create appropriately-sized canvas
  graphics = createGraphics(
    parseInt(props.getProperty("width", "1200")), 
    parseInt(props.getProperty("height", "750")),
    P3D);
  
  // VERY IMPORTANT: Allways initialize geomerative in the setup
  RG.init(this);
}

//render to off-screen buffer
void render(){
  graphics.beginDraw();
  graphics.clear();
  graphics.background(255);
  
  String text = props.getProperty("text", "some test");
  if (text != null && text.length() > 0 && trim(text).length() > 0){
    RShape sText = RG.getText(text, "FreeSans.ttf", 72, CENTER);
    RG.setPolygonizer(RG.ADAPTATIVE);
    RPoint[] pText = sText.getPoints();
    RMesh mText = sText.toMesh();
  
    graphics.fill(0);
    graphics.stroke(0);
    graphics.text(props.getProperty("text", text), 10, 20);
    graphics.translate(graphics.width/2, 100);
    sText.draw(graphics);
    graphics.translate(0, 50);
    for(int i = 0; pText != null && i < pText.length; i++){
     graphics.point(pText[i].x, pText[i].y);
    }
    graphics.translate(0, 50);
  
    mText.setFill(0);
    mText.draw(graphics);
  }
  graphics.endDraw();
}

void draw(){
  if(iteration == 0){
    render();
    graphics.save(props.getProperty("image", "testImage.png"));
  } else if (iteration == 1){
    if (hasProps){
      exit();
    } else {
      image(graphics, 0, 0, width, height);
    }
  }
  iteration++;
}