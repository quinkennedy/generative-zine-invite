import processing.pdf.*;
//for Map
import java.util.*;

Map<String, String> vars = new HashMap<String, String>();
Process currProcess;
PImage img;
String errorMsg = "";
GenerativeBox[] boxes;
int currBox = 0;

//
float margin = 50;
float paperWidthIn = 8.5; //inches
float paperHeightIn = 11; //inches
int desiredDPI = 300; //pixels per inch
int pdfDPI = 72;
int paperWidthPx = int(paperWidthIn * desiredDPI);
int paperHeightPx = int(paperHeightIn * desiredDPI);
// how many folds you want to create for your zine
int widthFolds = 1;
int heightFolds = 2;
int pageWidthPx = paperWidthPx / (int)Math.pow(2, widthFolds);
int pageHeightPx = paperHeightPx / (int)Math.pow(2, heightFolds);
//how many pages you plan to print on, 
//so for a quarter size book each printer page represents 8 of the book pages
int printerPages = 1; // double sided
int numPages = (int)Math.pow(2, widthFolds) * (int)Math.pow(2, heightFolds) * 2 * printerPages;
int topMargin = 200;
int bottomMargin = 300;
int centerLeft = 50;
int centerRight = 50;
ZinePageLayout[][][] zpl;
PGraphics pdf;

void setup () {
  size(700,700);
  pdf = createGraphics((int)(paperWidthIn * pdfDPI), (int)(paperHeightIn * pdfDPI), PDF, "zine.pdf");
  zpl = getLayout(heightFolds, widthFolds, printerPages*2);
  XML xml = loadXML("zine.xml");
  XML[] gens = xml.getChildren("generative");
  boxes = new GenerativeBox[gens.length];
  initvars(xml);
  for(int i = 0; i < boxes.length; i++){
    String imageLoc = vars.get("root_dir")+"images/image"+((int)random(0,1000000))+".png";
    vars.put("image_path", imageLoc);
    boxes[i] = new GenerativeBox(gens[i], vars, imageLoc, this);
  }
}

void initvars(XML xml){
  vars.put("num", str(0));
  vars.put("width", str(pageWidthPx));
  vars.put("height", str(pageHeightPx));
  
  String dataDir = dataPath("");
  String sketchDir = dataDir.substring(0, dataDir.lastIndexOf("/data"));
  String parentDir = sketchDir.substring(0, sketchDir.lastIndexOf("/") + 1);
  sketchDir += "/";
  
  vars.put("root_dir", parentDir);
  
  XML[] varWrap = xml.getChildren("vars");
  if (varWrap.length > 0){
    XML[] varList = varWrap[0].getChildren("var");
    for(int i = 0; i < varList.length; i++){
      XML[] key = varList[i].getChildren("key");
      XML[] value = varList[i].getChildren("value");
      if (key.length > 0 && value.length > 0){
        vars.put(parseAsText(key[0], vars), parseAsText(value[0], vars));
      }
    }
  }
}

void draw() {
  int cellsPerRow = zpl[0][0].length;
  int rowsPerPage = zpl[0].length;
  int pagesPerZine = zpl.length;
  int totalCells = pagesPerZine * rowsPerPage * cellsPerRow;
  if (currBox >= totalCells){
    noLoop();
    println("DONE!");
    pdf.dispose();
  } else {
    int cell = currBox % cellsPerRow;
    int row = (currBox / cellsPerRow) % rowsPerPage;
    int page = (currBox / cellsPerRow / rowsPerPage) % pagesPerZine;
    ZinePageLayout cpg = zpl[page][row][cell];
    if (cpg.getNumber() - 1 >= boxes.length){
      currBox++;
    } else {
      if (boxes[cpg.getNumber() - 1].isReady()){
        pdf.beginDraw();
        if (cell == 0 && row == 0 && page != 0){
          ((PGraphicsPDF)pdf).nextPage();
        }
        pdf.scale(((float)pdfDPI) / desiredDPI);
        pdf.translate(pageWidthPx*cell, pageHeightPx*row);
        if (cpg.getHFlip()){
          pdf.translate(pageWidthPx, pageHeightPx);
          pdf.scale(-1, -1);
        }
        boxes[cpg.getNumber() - 1].render(new Rectangle(0, 0, pageWidthPx, pageHeightPx), pdf, false);
        pdf.endDraw();
        currBox++;
      }
    }
  }
}

protected String parseAsText(XML txt, Map<String, String> vars){
  FormattedTextBlock text = new FormattedTextBlock(null);
  parse(txt, FontFamily.loadNone(), FontWeight.REGULAR, 
    FontEm.REGULAR, 0, vars, text);
  String output = "";
  for(int j = 0; j < text.text.size(); j++){
    output += text.text.get(j).text;
  }
  return output;
}
  
//so what I want is a recursive function which edits a list and returns a string.
//if it gets a string back, then it concatinates that string to it's own string, if there
//  were nodes added to the List after this function was entered, add this function's text to the List
protected void parse(XML txt, FontFamily fnt, FontWeight weight, FontEm em, 
    float size, Map<String, String> vars, FormattedTextBlock block){
  LinkedList<FormattedTextBlock.FormattedText> bits = 
    new LinkedList<FormattedTextBlock.FormattedText>();
  String result = parse(bits, txt, fnt, weight, em, size, vars);
  if (result != null && result.length() > 0){
    bits.add(new FormattedTextBlock.FormattedText(result, fnt.get(weight, em), size));
  }
  for(int i = 0; i < bits.size(); i++){
    block.add(bits.get(i));
  }
}

private String parse(
    LinkedList<FormattedTextBlock.FormattedText> bits, XML node, FontFamily fnt, 
    FontWeight weight, FontEm em, float size, Map<String, String> vars){
  FontWeight myWeight = weight;
  FontEm myEm = em;
  if (node == null){
    return null;
  }
  String currName = node.getName();
  if (currName.equals("#text")){
    return node.getContent();
  } else if (currName.equals("var")){
    if (vars.containsKey(node.getString("key"))){
      return vars.get(node.getString("key"));
    } else {
      return node.format(-1);
    }
  } else if (currName.equals("bold")){
    myWeight = FontWeight.BOLD;
  } else if (currName.equals("italic")){
    myEm = FontEm.ITALIC;
  }
  XML[] children = node.getChildren();
  String myText = "";
  int listLength = bits.size();
  for(XML child : children){
    String childText = parse(bits, child, fnt, myWeight, myEm, size, vars);
    if (bits.size() > listLength){
      if (myText.length() > 0){
        bits.add(listLength, new FormattedTextBlock.FormattedText(myText, fnt.get(myWeight, myEm), size));
        if (childText != null){
          myText = childText;
        } else {
          myText = "";
        }
      }
      listLength = bits.size();
    } else if (childText != null && childText.length() > 0){
      myText += childText;
    }
  }
  if (myText.length() > 0){
    bits.add(new FormattedTextBlock.FormattedText(myText, fnt.get(myWeight, myEm), size));
  }
  return null;
}