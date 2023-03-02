/*=========================================================================
 
 Name:        vnec.pde
 
 Author:      David Borland, The Renaissance Computing Institute (RENCI)
 
 Copyright:   The Renaissance Computing Institute (RENCI)
 
 Description: Processing sketch for vizualize necrotizing enterocolitis
              (vnec) tool.
 
=========================================================================*/


import java.util.*;
import controlP5.*;

PatientData data;
TimeSeriesView timeSeries = null;

ControlP5 gui = null;
CheckBox visible;
CheckBox lineBorders;
CheckBox ranges;

String screenshotName = "";

boolean disableGUI = false;  
int guiWidth = 280;

PFont font;
PFont fontSmall;
int fontSize = 16;

void setup() {
  // Processing setup
  // Standard canvas has better text and line drawing, but doesn't allow color per vertex, and leaves gaps between quads when zoomed in (with smoothing on...).
  // P3D has okay text and line drawing, but does allow color per vertex without gaps between quads.
//  size(2400, 800, P3D);
    size(2400, 1200, P3D);
//  size(1500, 600, P3D);
//  size(displayWidth, displayHeight, P3D);

//  smooth(2);
  
  colorMode(RGB, 1.0);
  
  font = createFont("Arial", fontSize, true);
  textFont(font);
  
  fontSmall = createFont("Arial", 12, true);
    
  selectInput("Hello!", "FileSelected");  
}

void FileSelected(File file) {
  if (file == null) {
    return;
  }
  
  String fileName1 = file.getAbsolutePath();
  String fileName2 = fileName1.replace(".csv", "_DataCodes.csv");
  
  // Load data
  data = new PatientData();
  data.ReadData(fileName1, fileName2);
  
    
  // Create visualization
  timeSeries = new TimeSeriesView((float)guiWidth / width + 0.05, 0.1, 0.9, 0.9);
  timeSeries.SetPatientData(data);
  
  
  // Create GUI
  if (gui == null){
    CreateGUI();
  }
  else {
    // XXX: Currently GUI gets out of synch with TimeSeriesView upon loading a new file, but it doesn't crash :-)
//    RefreshGUI(); 
  }
}

void ScreenshotSelected(File file) {
  screenshotName = file.getAbsolutePath();
}

void CreateGUI() {
  gui = new ControlP5(this); 
  
  Group g1 = gui.addGroup("Controls")
                .setBackgroundColor(color(1.0, 1.0, 1.0))
                .setBackgroundHeight(height)
                .setWidth(guiWidth);
                ;
                
  visible = gui.addCheckBox("visible")
               .setItemWidth(20)
               .setItemHeight(20)
               .addItem("a", 0)
               .addItem("b", 1)
               .addItem("c", 2)
               .addItem("d", 3)
               .addItem("e", 4)
               .addItem("f", 5)
               .addItem("g", 6)
               .addItem("h", 7)
               .addItem("i", 8)
               .addItem("j", 9)
               .setColorLabel(color(0.5, 0.5, 0.5, 0.01))
               .moveTo(g1)
               ;
                
  gui.addSlider("abdominal")
     .setRange(0.0, 1.0)
     .setValue(0.5)
     .setColorLabel(color(0.0, 0.0, 1.0))
     .setPosition(25, 6)
     .moveTo(g1)
     ;
  gui.addSlider("foot")
     .setRange(0.0, 1.0)
     .setValue(0.5)
     .setColorLabel(color(1.0, 0.0, 0.0))
     .setPosition(25, 27)
     .moveTo(g1)
     ;
   gui.addSlider("abdominalFootDifference")
      .setRange(0.0, 1.0)
      .setValue(1.0)
      .setColorLabel(color(0.5, 0.5, 0.5))
      .setPosition(25, 48)
      .moveTo(g1)
      ;
   gui.addSlider("abdominalFootAverage")
      .setRange(0.0, 1.0)
      .setValue(0.5)
      .setColorLabel(color(1.0, 0.0, 1.0))
      .setPosition(25, 69)
      .moveTo(g1)
      ;
   gui.addSlider("external")
      .setRange(0.0, 1.0)
      .setValue(0.5)
      .setColorLabel(color(0.0, 1.0, 0.0))
      .setPosition(25, 90)
      .moveTo(g1)
      ;
   gui.addSlider("averageExternalDifference")
      .setRange(0.0, 1.0)
      .setValue(1.0)
      .setColorLabel(color(0.5, 0.5, 0.5))
      .setPosition(25, 111)
      .moveTo(g1)
      ;
   gui.addSlider("servo")
      .setRange(0.0, 1.0)
      .setValue(0.5)
      .setColorLabel(color(0.0, 0.0, 0.0))
      .setPosition(25, 132)
      .moveTo(g1)
      ;
      
   gui.addSlider("meanPI")
      .setRange(0.0, 1.0)
      .setValue(0.5)
      .setColorLabel(color(0.75, 0.75, 0.0))
      .setPosition(25, 153)
      .moveTo(g1)
      ;
      
   gui.addSlider("heartRate")
      .setRange(0.0, 1.0)
      .setValue(0.5)
      .setColorLabel(color(0.0, 0.75, 0.75))
      .setPosition(25, 174)
      .moveTo(g1)
      ;
      
   gui.addSlider("auc")
      .setRange(0.0, 0.5)
      .setValue(0.25)
      .setColorLabel(color(0.5, 0.5, 0.5))
      .setPosition(25, 195)
      .moveTo(g1)
      ;
      
  lineBorders = gui.addCheckBox("lineBordersCheckBox")
                   .setPosition(0, 216)
                   .setItemWidth(20)
                   .setItemHeight(20)
                   .addItem("lineBorders", 0)
                   .setColorLabel(color(0.0, 0.0, 0.0))
                   .moveTo(g1)
                   ;
                     
  gui.addBang("openFile")
     .setPosition(0, 242)
     .setSize(30, 30)
     .setColorLabel(color(0.0, 0.0, 0.0))
     ; 
                   
                   
  ranges = gui.addCheckBox("rangesCheckBox")
                 .setPosition(0, 302)
                 .setItemWidth(20)
                 .setItemHeight(20)
                 .addItem("ranges", 0)
                 .setColorLabel(color(0.0, 0.0, 0.0, 0.01))
                 .moveTo(g1)
                 ;
                   
  gui.addSlider("rangeKernel") 
//     .setRange(0, data.externalTemp.size() / 100)
.setRange(0, 1440)
     .setValue(data.externalTemp.size() / 100)
     .setColorLabel(color(0.5, 0.5, 0.5))
     .setPosition(25, 302)
     .moveTo(g1)
     ;  
     
  gui.addSlider("rangeOpacity") 
     .setRange(0.0, 1.0)
     .setValue(0.5)
     .setColorLabel(color(0.5, 0.5, 0.5))
     .setPosition(25, 314)
     .moveTo(g1)
     ;  
     
     

  gui.addBang("saveScreenshot")
     .setPosition(0, 336)
     .setSize(30, 30)
     .setColorLabel(color(0.0, 0.0, 0.0))
     ;
                
//  Accordion accordion = gui.addAccordion("accordion")
//                           .addItem(g1)
//                           .setWidth(guiWidth);
//                           ;                       
                                           
  RefreshGUI(); 
}


void openFile() {
  selectInput("Hello!", "FileSelected");  
}

void saveScreenshot() {
  selectOutput("Hello!", "ScreenshotSelected");
}


void abdominal(float opacity) {
  timeSeries.abdominalOpacity = opacity;
} 

void foot(float opacity) {
  timeSeries.footOpacity = opacity;
} 

void abdominalFootDifference(float opacity) {
  timeSeries.abdominalFootDifferenceOpacity = opacity;
} 

void abdominalFootAverage(float opacity) {
  timeSeries.abdominalFootAverageOpacity = opacity;
} 

void external(float opacity) {
  timeSeries.externalOpacity = opacity;
} 

void averageExternalDifference(float opacity) {
  timeSeries.averageExternalDifferenceOpacity = opacity;
} 

void servo(float opacity) {
  timeSeries.servoOpacity = opacity;
} 

void meanPI(float opacity) {
  timeSeries.meanPIOpacity = opacity;
} 

void heartRate(float opacity) {
  timeSeries.heartRateOpacity = opacity;
} 

void auc(float value) {
  timeSeries.aucDifference = value; 
}

void rangeKernel(float value) {
  data.SetKernelRadius((int)value); 
}

void rangeOpacity(float opacity) {
  timeSeries.rangeOpacity = opacity;
}

void controlEvent(ControlEvent theEvent) {
  if (disableGUI) return;
  
  if (theEvent.isFrom(visible)) {
    for (int i = 0; i< visible.getArrayValue().length; i++) {
      int v = (int)visible.getArrayValue()[i];
      
      switch(i) {
        
        case 0:
          timeSeries.showAbdominal = v == 1;
          break;
          
        case 1:
          timeSeries.showFoot = v == 1;
          break;
          
        case 2:
          timeSeries.showAbdominalFootDifference = v == 1;
          break;
          
        case 3:
          timeSeries.showAbdominalFootAverage = v == 1;
          break;
          
        case 4:
          timeSeries.showExternal = v == 1;
          break;
          
        case 5:
          timeSeries.showAverageExternalDifference = v == 1;
          break;
          
        case 6:
          timeSeries.showServo = v == 1;
          break;
          
        case 7:
          timeSeries.showMeanPI = v == 1;
          break;
          
        case 8:
          timeSeries.showHeartRate = v == 1;
          break;
          
        case 9:
          timeSeries.showDay = v == 1;
          break;
      }
    }
  } 
  else if (theEvent.isFrom(lineBorders)) {
    timeSeries.lineBorders = (int)lineBorders.getArrayValue()[0] == 1;
  } 
  else if (theEvent.isFrom(ranges)) {
    timeSeries.ranges = (int)ranges.getArrayValue()[0] == 1;
  } 
}


void RefreshGUI() {  
  disableGUI = true;
  
  // Checkbox
  if (timeSeries.showAbdominal) {
    visible.activate(0); 
  }
  
  if (timeSeries.showFoot) {
    visible.activate(1); 
  }
  
  if (timeSeries.showAbdominalFootDifference) {
    visible.activate(2); 
  }
  
  if (timeSeries.showAbdominalFootAverage) {
    visible.activate(3); 
  }
  
  if (timeSeries.showExternal) {
    visible.activate(4); 
  }
  
  if (timeSeries.showAverageExternalDifference) {
    visible.activate(5); 
  }
  
  if (timeSeries.showServo) {
    visible.activate(6); 
  }  
  
  if (timeSeries.showMeanPI) {
    visible.activate(7); 
  }  
  
  if (timeSeries.showHeartRate) {
    visible.activate(8); 
  }  
  
  if (timeSeries.showDay) {
    visible.activate(9); 
  }
  
  disableGUI = false;
}

void draw() {  
  background(1.0, 1.0, 1.0);
  
  if (timeSeries == null) {
    return; 
  }
  
  timeSeries.Draw();
  
  if (screenshotName.length() > 0) {
     save(screenshotName);
     screenshotName = "";
  }
}

void keyPressed() {  
  switch (key) {
    
    // Show individual plots
    case '1':
      timeSeries.showAbdominal = !timeSeries.showAbdominal;
      break;
      
    case '2':
      timeSeries.showFoot = !timeSeries.showFoot;
      break;
      
    case '3':
      timeSeries.showAbdominalFootDifference = !timeSeries.showAbdominalFootDifference;
      break;
      
    case '4':
      timeSeries.showAbdominalFootAverage = !timeSeries.showAbdominalFootAverage;
      break;
      
    case '5':
      timeSeries.showExternal = !timeSeries.showExternal;
      break;
      
    case '6':
      timeSeries.showAverageExternalDifference = !timeSeries.showAverageExternalDifference;
      break;
      
    case '7':
      timeSeries.showServo = !timeSeries.showServo;
      break;
      
    case '8':
      timeSeries.showMeanPI = !timeSeries.showMeanPI;
      break;
      
    case '9':
      timeSeries.showHeartRate = !timeSeries.showHeartRate;
      break;
      
      
    // Line borders
    case 'l':
      timeSeries.lineBorders = !timeSeries.lineBorders;
      break;
      
          
    // Pan and zoom
    case 'a':
      timeSeries.Pan(-20);
      break;
      
    case 'd':
      timeSeries.Pan(20);
      break;
    
    case 'w':      
      timeSeries.Zoom(-1.0);
      break;
      
    case 's':      
      timeSeries.Zoom(1.0);
      break;
      
      
    // Save screenshot image
    case 'i':
      saveScreenshot();
      break;
  }
}

void mousePressed() {
  timeSeries.MousePressed();
}

void mouseDragged() {
  timeSeries.MouseDragged();
}

void mouseReleased() {
  timeSeries.MouseReleased();
}

void mouseWheel(MouseEvent event) {
  timeSeries.MouseWheel(event); 
}

void mouseMoved() {
}
