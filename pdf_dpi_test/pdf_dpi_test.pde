/**
 * PDF DPI Test
 * A test program to see if pdf size/resolution effects image quality
 * There are 3 tests:
 * 1. a large image, included at "native res" in a large PDF
 * 2. a down-scaled image, included at "native res" in a small PDF
 * 3. a large image, included at a small scale in a small PDF (the real test)
 *
 * Why:
 * The PDF renderer has no way of setting the DPI, it is fixed at 72dpi
 * What this means is, when you try to print the PDF, if you create it
 * with the intention of a 300dpi quality (for printing), its dimensions
 * are very large (35.5" x 46" instead of 8.5" x 11"). This makes it
 * difficult to find the correct settings for printing.
 * 
 * Findings:
 * 1. when the PDF is viewed at 100% scale, the image looks as expected.
 * 2. when the PDF is viewed at 416% scale (to match the size of the large PDF)
 *    the image is severely pixelated.
 * 3. when the PDF is viewed at 416% scale, the image looks just as good as case #1
 *
 * Results:
 * This is good news. This means you can create a PDF renderer of any pixel 
 * dimensions (to control the resulting physical dimensions), and still render
 * high-resolution content appropriate for print-quality work.
 *
 * TODO:
 * Actually print out sample PDFs to confirm findings.
 *
 */

import processing.pdf.*;

PGraphics graphiclg, graphicsm;
PGraphics pdfsm, pdflg, pdfsmsm;

float widthIn = 3;
float heightIn = 3;
float smDPI = 72;
float lgDPI = 300;

void setup(){
  size(400, 400, P2D);
  graphiclg = createGraphics((int)(lgDPI * widthIn), (int)(lgDPI * heightIn), P2D);
  graphicsm = createGraphics((int)(smDPI * widthIn), (int)(smDPI * heightIn), P2D);
  pdfsm = createGraphics((int)(smDPI * widthIn), (int)(smDPI * heightIn), PDF, "pdfsm.pdf");
  pdflg = createGraphics((int)(lgDPI * widthIn), (int)(lgDPI * heightIn), PDF, "pdflg.pdf");
  pdfsmsm = createGraphics((int)(smDPI * widthIn), (int)(smDPI * heightIn), PDF, "pdfsmsm.pdf");
  noLoop();
}

void draw(){
  //create source graphic
  graphiclg.beginDraw();
  graphiclg.background(0);
  graphiclg.stroke(255);
  graphiclg.fill(180);
  graphiclg.text("hello there", 20, 100);
  graphiclg.ellipse(20, 20, 5, 5);
  graphiclg.line(100, 0, graphiclg.width, graphiclg.height);
  graphiclg.endDraw();
  
  //draw to screen for confirmation
  image(graphiclg, 0, 0, width, height);
  
  //create down-sampled version
  graphicsm.beginDraw();
  graphicsm.image(graphiclg, 0, 0, graphicsm.width, graphicsm.height);
  graphicsm.endDraw();
  
  //render original graphic to large PDF
  pdflg.beginDraw();
  pdflg.image(graphiclg, 0, 0);
  pdflg.dispose();
  pdflg.endDraw();
  
  //render original graphic to small PDF
  pdfsm.beginDraw();
  pdfsm.scale(smDPI/lgDPI);
  pdfsm.image(graphiclg, 0, 0);
  pdfsm.dispose();
  pdfsm.endDraw();
  
  //render down-sampled image to small PDF
  pdfsmsm.beginDraw();
  pdfsmsm.image(graphicsm, 0, 0);
  pdfsmsm.dispose();
  pdfsmsm.endDraw();
}