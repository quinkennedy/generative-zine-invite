
static class FontFamily{
  Map<FontWeight, Map<FontEm, PFont>> fonts;
  
  private FontFamily(){
    fonts = new HashMap<FontWeight, Map<FontEm, PFont>>();
  }
  
  public void loadFont(FontWeight w, FontEm e, String path, float size, PApplet p){
    PFont f = p.createFont(path, size);
    if (!fonts.keySet().contains(w)){
      fonts.put(w, new HashMap<FontEm, PFont>());
    }
    Map<FontEm, PFont> currWeight = fonts.get(w);
    currWeight.put(e, f);
  }
  
  public PFont getReg(){
    return get(FontWeight.REGULAR, FontEm.REGULAR);
  }
  
  public PFont get(FontWeight w, FontEm e){
    if (fonts.keySet().contains(w) && fonts.get(w).keySet().contains(e)){
      return fonts.get(w).get(e);
    } else {
      return null;
    }
  }
  
  public static FontFamily loadBody(PApplet p){
    FontFamily fam = new FontFamily();
    fam.loadFont(FontWeight.REGULAR, FontEm.REGULAR, "fonts/source-serif-pro/TTF/SourceSerifPro-Regular.ttf", 48, p);
    fam.loadFont(FontWeight.BOLD, FontEm.REGULAR, "fonts/source-serif-pro/TTF/SourceSerifPro-Bold.ttf", 48, p);
    fam.loadFont(FontWeight.REGULAR, FontEm.ITALIC, "fonts/source-sans-pro/TTF/SourceSansPro-It.ttf", 48, p);
    fam.loadFont(FontWeight.BOLD, FontEm.ITALIC, "fonts/source-sans-pro/TTF/SourceSansPro-BoldIt.ttf", 48, p);
    return fam;
  }
  
  public static FontFamily loadHeading(PApplet p){
    FontFamily fam = new FontFamily();
    fam.loadFont(FontWeight.REGULAR, FontEm.REGULAR, "fonts/source-sans-pro/TTF/SourceSansPro-Bold.ttf", 48, p);
    fam.loadFont(FontWeight.LIGHT, FontEm.REGULAR, "fonts/source-sans-pro/TTF/SourceSansPro-Semibold.ttf", 48, p);
    return fam;
  }
  
  public static FontFamily loadSingle(String path, float size, PApplet p){
    FontFamily fam = new FontFamily();
    fam.loadFont(FontWeight.REGULAR, FontEm.REGULAR, path, size, p);
    return fam;
  }
  
  public static FontFamily loadNone(){
    return new FontFamily();
  }
}

enum FontWeight{
  EXTRA_LIGHT, LIGHT, REGULAR, SEMI_BOLD, BOLD, BLACK;
}

enum FontEm{
  REGULAR, ITALIC
}