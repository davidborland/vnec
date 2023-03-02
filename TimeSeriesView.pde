/*=========================================================================
 
 Name:        TimeSeriesView.pde
 
 Author:      David Borland, The Renaissance Computing Institute (RENCI)
 
 Copyright:   The Renaissance Computing Institute (RENCI)
 
 Description: View of time series data from pediatric necrotizing
              enterocolitis data.
 
=========================================================================*/


// XXX: Need to make this more generic.  Create plot classes that can hold name, opacity, color, etc. to make 
// setting values easier.


class TimeSeriesView {
  // The data for the patient
  private PatientData data;
  
  private List<Float> abdominalFootAverage;
  
  // Number of data values for time-series data
  public int numValues;
  
  // Minimum and maximum y-axis values
  private float ySplit;
  
  private float tempMin;
  private float tempMax;
  
  // Range of indeces to display  
  private int viewMin;
  private int viewMax;
  
  // Maximum absolute value of difference between abdominal and foot temperature 
  private float maxAbdominalFootDiff;
  
  private float maxAverageExternalDiff;
  
  // Show plots or not
  public boolean showDay;  
  public boolean showAbdominal;
  public boolean showFoot;
  public boolean showAbdominalFootDifference;
  public boolean showAbdominalFootAverage;
  public boolean showExternal;
  public boolean showAverageExternalDifference;
  public boolean showServo;
  public boolean showMeanPI;
  public boolean showHeartRate;
  
  public float aucDifference;
  public float abdominalOpacity;
  public float footOpacity;
  public float abdominalFootDifferenceOpacity;
  public float abdominalFootAverageOpacity;
  public float externalOpacity;
  public float averageExternalDifferenceOpacity;
  public float servoOpacity;
  public float meanPIOpacity;
  public float heartRateOpacity;
  
  public boolean lineBorders;
  public boolean ranges;
  
  public float rangeOpacity;
  
  // Axis placement on the screen, in normalized coordinates
  private float xMin;
  private float xMax;
  private float yMin;
  private float yMax;
  
  // Interaction
  int zoomPoint;
  int oldMouseX;
  int oldMouseY;
 
  boolean interact;
 
  TimeSeriesView() {
    this(0.1, 0.1, 0.9, 0.9);
  }
  
  TimeSeriesView(float xMin, float yMin, float xMax, float yMax) { 
    showDay = true;
    showAbdominal = true;
    showFoot = true;
    showAbdominalFootDifference = false;
    showAbdominalFootAverage = false;
    showExternal = true;
    showAverageExternalDifference = false;
    showServo = true;
    showMeanPI = true;
    showHeartRate = true;
    
    aucDifference = 0.25;
    abdominalOpacity = 0.5;
    footOpacity = 0.5;
    abdominalFootDifferenceOpacity = 1.0;
    abdominalFootAverageOpacity = 0.5;
    externalOpacity = 0.5;
    averageExternalDifferenceOpacity = 1.0;
    servoOpacity = 0.5;
    meanPIOpacity = 0.5;
    heartRateOpacity = 0.5;
    
    lineBorders = false;
    ranges = false;
    
    rangeOpacity = 0.5;
    
    this.xMin = xMin;
    this.yMin = yMin;
    this.xMax = xMax;
    this.yMax = yMax;
    
    interact = false;
    
    ySplit = 0.75;
  }
  
  public void SetPatientData(PatientData data) {
    this.data = data; 
    
    numValues = data.abdominalTemp.size();
    
    abdominalFootAverage = new ArrayList<Float>();
    for (int i = 0; i < numValues; i++) {
      if (data.abdominalTemp.get(i) <= 0.0 || data.footTemp.get(i) <= 0.0) {
        abdominalFootAverage.add(0.0);
      }
      else {
        abdominalFootAverage.add((data.abdominalTemp.get(i) + data.footTemp.get(i)) * 0.5);
      }
    }
    
    viewMin = 0;
    viewMax = numValues - 1;
    
    // Find the maximum and minimum temperature values
//    SetTemperatureRange();

    tempMin = 25.0;
    tempMax = 40.0;
    
    maxAbdominalFootDiff = GetMaxDiff(data.abdominalTemp, data.footTemp);
    maxAverageExternalDiff = GetMaxDiff(abdominalFootAverage, data.externalTemp);
  }
  
  public void Draw() {
    DrawData();
    DrawXAxis(10);
    
    // Number of vertical labels   
    int spacing = 10;    
    DrawYAxis((int)min((tempMax - tempMin + 1) / 1, (height * (yMax - yMin) / (fontSize + spacing))));
  }
  
  private void DrawData() {    
    // Day
    if (showDay) {
      DrawDays();
    }   
    
    // Draw time step information
    DrawTimeStepInfo(); 
    
    if (ranges) {
      if (showAbdominal) {
        DrawTempRange(data.abdominalMin, data.abdominalMax, color(0.5, 0.5, 1.0, rangeOpacity)); 
      }
      if (showFoot) {
        DrawTempRange(data.footMin, data.footMax, color(1.0, 0.5, 0.5, rangeOpacity));
      }
      if (showExternal) {
        DrawTempRange(data.externalMin, data.externalMax, color(0.5, 1.0, 0.5, rangeOpacity));
      }      
      if (showMeanPI) {
        DrawNormalizedRange(data.meanPIMin, data.meanPIMax, color(0.75, 0.75, 0.25, rangeOpacity), 0.0, 20.0);
      }      
      if (showHeartRate) {
        DrawNormalizedRange(data.heartRateMin, data.heartRateMax, color(0.25, 0.75, 0.75, rangeOpacity), 60.0, 230.0);
      }
    }
    
    // Abdominal temperature
    if (showAbdominal) {
      if (lineBorders) {
        DrawTempData(data.abdominalTemp, color(1.0, 1.0, 1.0), 5.0);
      }
      
      DrawTempData(data.abdominalTemp, color(0.0, 0.0, 1.0, abdominalOpacity), 1.0);
    }
    
    // Foot temperature
    if (showFoot) {
      if (lineBorders) {
        DrawTempData(data.footTemp, color(1.0, 1.0, 1.0), 5.0);
      }

      DrawTempData(data.footTemp, color(1.0, 0.0, 0.0, footOpacity), 1.0);
    }

    // Abdominal and foot temperature
    if (showAbdominalFootDifference) {
      DrawTempDifference(data.footTemp, color(1.0, 0.0, 0.0), data.abdominalTemp, color(0.0, 0.0, 1.0), maxAbdominalFootDiff, abdominalFootDifferenceOpacity, true);
      DrawTempDifference(data.footTemp, color(1.0, 0.0, 0.0), data.abdominalTemp, color(0.0, 0.0, 1.0), maxAbdominalFootDiff, abdominalFootDifferenceOpacity, false);
    }
    
    // Abdominal foot average
    if (showAbdominalFootAverage) {
      if (lineBorders) {
        DrawTempData(abdominalFootAverage, color(1.0, 1.0, 1.0), 5.0);
      }
      DrawTempData(abdominalFootAverage, color(1.0, 0.0, 1.0, abdominalFootAverageOpacity), 1.0);
    }
    
    // External temperature
    if (showExternal) {      
      if (lineBorders) {
        DrawTempData(data.externalTemp, color(1.0, 1.0, 1.0), 5.0);
      }

      DrawTempData(data.externalTemp, color(0.0, 1.0, 0.0, externalOpacity), 1.0);
    }
    
    // Abdominal/foot average and external
   if (showAverageExternalDifference) {
     DrawTempDifference(abdominalFootAverage, color(1.0, 0.0, 1.0), data.externalTemp, color(0.0, 1.0, 0.0), maxAverageExternalDiff, averageExternalDifferenceOpacity, true);
//     DrawTempDifference(abdominalFootAverage, color(1.0, 0.0, 1.0), data.externalTemp, color(0.0, 1.0, 0.0), maxAverageExternalDiff, averageExternalDifferenceOpacity, false);
   } 
    
    // Servo temperature
    if (showServo) {
      if (lineBorders) {
        DrawTempData(data.servoTemp, color(1.0, 1.0, 1.0), 5.0);
      }
      DrawTempData(data.servoTemp, color(0.0, 0.0, 0.0, max(0.01, servoOpacity)), 1.0);
    }
    
    if (showMeanPI) {
      if (lineBorders) {
        DrawMeanPI(color(1.0, 1.0, 1.0), 5.0);
      }
      DrawMeanPI(color(0.75, 0.75, 0.0, meanPIOpacity), 1.0);
    }
    
    if (showHeartRate) {
      if (lineBorders) {
        DrawHeartRate(color(1.0, 1.0, 1.0), 5.0);
      }
      DrawHeartRate(color(0.0, 0.75, 0.75, heartRateOpacity), 1.0);
    }          
  }
  
  private void DrawTimeStepInfo() {   
    // Info for this time step   
    int index = (int)map(mouseX, xMin * width, xMax * width, viewMin, viewMax);
    index = constrain(index, viewMin, viewMax);

    
    stroke(0.0, 0.0, 0.0, 0.5);
    strokeWeight(1);
    float x = constrain(mouseX, xMin * width, xMax * width);
    line(x, yMin * height, x, yMax * height);
//    float y = Temp2Screen(max(data.abdominalTemp.get(index), max(data.footTemp.get(index), max(data.externalTemp.get(index), data.servoTemp.get(index)))));
//    line(x, y, x, yMax * height);
    
    
    textAlign(LEFT, CENTER);
    
    fill(0.0, 0.0, 0.0);   
    
    float fade = 0.25;
    
    float a = data.abdominalTemp.get(index); 
    fill(color(0.0, 0.0, 1.0, a > 0.0 ? 1.0 : fade));   
    text("Abdominal: " + (a > 0.0 ? String.format("%.2f", a) : "NA"), (xMax + 0.01) * width, (yMin + 0.2) * height);
    
    float f = data.footTemp.get(index);
    fill(color(1.0, 0.0, 0.0, f > 0.0 ? 1.0 : fade)); 
    text("Foot: " + (f > 0.0 ? String.format("%.2f", f) : "NA"), (xMax + 0.01) * width, (yMin + 0.23) * height);
        
    color c = a >= f ? color(0.0, 0.0, 1.0) : color(1.0, 0.0, 0.0);
//    fill(color(red(c), green(c), blue(c), abs(t1 - t2) / maxDiff * maxOpacity));    
    fill(a > 0.0 && f > 0.0 ? color(c) : color(0.0, 0.0, 0.0, fade));
    text("Abdominal - Foot: " + (a > 0.0 && f > 0.0 ? String.format("%.2f", a - f) : "NA"), (xMax + 0.01) * width, (yMin + 0.26) * height);
    
    float e = data.externalTemp.get(index);
    fill(e > 0.0 ? color(0.0, 1.0, 0.0) : color(0.0, 1.0, 0.0, fade));
    text("External: " + (e > 0.0 ? String.format("%.2f", e) : "NA"), (xMax + 0.01) * width, (yMin + 0.29) * height);
    
    float s = data.servoTemp.get(index);
    fill(s > 0.0 ? color(0.0, 0.0, 0.0) : color(0.0, 0.0, 0.0, fade));
    text("Servo: " + (s > 0.0 ? String.format("%.2f", s) : "NA"), (xMax + 0.01) * width, (yMin + 0.32) * height);

    float mpi = data.meanPI.get(index);   
    fill(mpi > 0.0 ? color(0.75, 0.75, 0.0) : color(0.75, 0.75, 0.0, fade));
    text("Mean PI: " + (mpi > 0.0 ? String.format("%.2f", mpi) : "NA"), (xMax + 0.01) * width, (yMin + 0.35) * height);
    
    float hr = data.heartRate.get(index);
    fill(hr > 0.0 ? color(0.0, 0.75, 0.75) : color(0.0, 0.75, 0.75, fade));
    text("Heart Rate: " + (hr > 0.0 ? String.format("%.0f", hr) : "NA"), (xMax + 0.01) * width, (yMin + 0.38) * height);
  }
  
  private void DrawDays() {
    List<Integer> day = data.day;
    
    // AUC    
    color c1 = color(1.0, 1.0, 1.0);
    color c2 = color(1.0 - aucDifference, 1.0 - aucDifference, 1.0 - aucDifference);
//    color c1 = color(1.0 - aucDifference, 1.0 - aucDifference, 1.0 - aucDifference);
//    color c2 = color(1.0, 1.0, 1.0);
    color c3 = color(1.0, 1.0, 1.0);
    
    noStroke();
    
    beginShape(QUAD_STRIP);
    
//    c = day.get(viewMin) %2 == 0 ? c1 : c2;
    int d = day.get(viewMin) - 1; 
    fill(d < data.auc.size() ? lerpColor(c1, c2, data.auc.get(d)) : c3);
    
    float x = Step2Screen(viewMin);
    vertex(x, yMax * height);
 //   vertex(x, yMin * height);
vertex(x, 0);
    
    for (int i = viewMin + 1; i <= viewMax; i++) {           
      if (day.get(i) != day.get(i - 1)) {   
        // New day        
        x = Step2Screen(i);        
        vertex(x, yMax * height);
//        vertex(x, yMin * height);
vertex(x, 0);
        
//        fill(day.get(i) % 2 == 0 ? c1 : c2);
        d = day.get(i) - 1; 
        fill(d < data.auc.size() ? lerpColor(c1, c2, data.auc.get(d)) : c3);
        
        vertex(x, yMax * height);
//        vertex(x, yMin * height);
vertex(x, 0);
      }
    } 
    
    x = Step2Screen(viewMax);
    vertex(x, yMax * height);
//    vertex(x, yMin * height);
vertex(x, 0);
    
    endShape();
    
    
    // Text
    // Need a separate loop because we can't put text calls between vertices       
    textAlign(CENTER, TOP);
    
    fill(0.0, 0.0, 0.0);
    
    int dayStart = viewMin;
    for (int i = viewMin + 1; i <= viewMax; i++) {           
      if (day.get(i) != day.get(i - 1)) {   
        x = Step2Screen((i - 1 + dayStart) / 2);
        text(day.get(i - 1), x, (yMin - 0.07) * height);
        
        d = day.get(i - 1) - 1;
        if (d < data.auc.size()) {
          text(data.auc.get(d), x, (yMin - 0.02) * height);

          String dataCodes = "";
          for (int j = 0; j < data.dataCodes.get(d).size(); j++) {
            if (j == 0) {
              dataCodes = data.dataCodes.get(d).get(j); 
            }
            else {
              dataCodes = dataCodes + ", " + data.dataCodes.get(d).get(j);
            }  
          }
        
          textFont(fontSmall);
          text(dataCodes, x, (yMin - 0.045) * height);
          textFont(font);
        }
       
        dayStart = i; 
      }
    } 
    
    // Draw the last day
    x = Step2Screen((viewMax + dayStart) / 2);
    text(day.get(viewMax), x, (yMin - 0.07) * height);
    
    d = day.get(viewMax) - 1;
    if (d < data.auc.size()) {
      text(data.auc.get(d), x, (yMin - 0.02) * height);    
      
      String dataCodes = "";
      for (int j = 0; j < data.dataCodes.get(d).size(); j++) {
        if (j == 0) {
          dataCodes = data.dataCodes.get(d).get(j); 
        }
        else {
          dataCodes = dataCodes + ", " + data.dataCodes.get(d).get(j);
        }  
      }
      
      textFont(fontSmall);
      text(dataCodes, x, (yMin - 0.045) * height);
      textFont(font);
    }
        
    textAlign(LEFT, TOP);
    x = (xMax + 0.02) * width;
    text("Day", x, (yMin - 0.07) * height);
    text("Medical Codes", x, (yMin - 0.045) * height);
    text("AUC-I", x, (yMin - 0.02) * height);
        
    textAlign(CENTER, TOP);
    text("Patient: " + data.patient, (xMin + (xMax - xMin) * 0.5) * width, 10);
  }
  
  private void DrawMeanPI(color c, float weight) {
    List<Float> mpi = data.meanPI;
    
    noFill();
    stroke(c);
    strokeWeight(weight);  
    
    beginShape();
    for (int i = viewMin; i <= viewMax; i++) {
      // XXX: Problem, 0 is a valid value for mean PI
      if (mpi.get(i) < 0.0) {
        endShape();
        beginShape();
        continue; 
      }
      
      float x = Step2Screen(i);
      float y = map(mpi.get(i), 0.0, 20.0, yMax * height, map(ySplit, 0.0, 1.0, yMin * height, yMax * height));
      
      vertex(x, y);
    }
    endShape();
  }
  
  private void DrawHeartRate(color c, float weight) {
    List<Float> hr = data.heartRate;
    
    noFill();
    stroke(c);
    strokeWeight(weight);  
    
    beginShape();
    for (int i = viewMin; i <= viewMax; i++) {
      // Hack to account for missing data
      if (hr.get(i) <= 0.0) {
        endShape();
        beginShape();
        continue; 
      }
      
      float x = Step2Screen(i);
      float y = map(hr.get(i), 60.0, 230.0, yMax * height, map(ySplit, 0.0, 1.0, yMin * height, yMax * height));
      
      vertex(x, y);
    }
    endShape();
  }
  
  private void DrawTempData(List<Float> temp, color c, float weight) {   
//    int highlight = (int)map(constrain(mouseX, xMin * width, xMax * width), xMin * width, xMax * width, viewMin, viewMax);
      
//    stroke(0.0, 0.0, 0.0, 0.5);
//    strokeWeight(1);
//    noStroke();
//    fill(1.0, 1.0, 1.0, 1.0);
      
//    ellipse(Step2Screen(highlight), Temp2Screen(temp.get(highlight)), 15, 15);

//    stroke(0.0, 0.0, 0.0);
//    strokeWeight(1);
//    line(Step2Screen(highlight), Temp2Screen(temp.get(highlight)) - 5, Step2Screen(highlight), Temp2Screen(temp.get(highlight)) + 5//);
 
 
   
    noFill();
    stroke(c);
    strokeWeight(weight);  
    
    beginShape();
    for (int i = viewMin; i <= viewMax; i++) {
      // Hack to account for missing data
      if (temp.get(i) <= 0.0) {
        endShape();
        beginShape();
        continue; 
      }
      
      float x = Step2Screen(i);
      float y = Temp2Screen(temp.get(i));
      
      vertex(x, y);
    }
    endShape();
  }
  
  private void DrawTempDifference(List<Float> temp1, color c1, List<Float> temp2, color c2, float maxDiff, float maxOpacity, boolean absolute) {
    noStroke();
 
    beginShape(QUAD_STRIP);
    for (int i = viewMin; i <= viewMax; i++) {      
      float t1 = temp1.get(i);
      float t2 = temp2.get(i);
      
      // Hack to account for missing data
      if (t1 <= 0.0 || t2 <= 0.0) {
        endShape();
        beginShape(QUAD_STRIP);
        continue; 
      }
      
      float x1 = Step2Screen(i);
      float y1 = Temp2Screen(t1);
      
      float x2 = Step2Screen(i);
      float y2 = Temp2Screen(t2);
      
      color c = t1 > t2 ? c1 : c2;
      fill(color(red(c), green(c), blue(c), abs(t1 - t2) / maxDiff * maxOpacity));
      
//      c = color(red(c) * maxOpacity, green(c) * maxOpacity, blue(c) * maxOpacity);      
//      fill(lerpColor(color(1.0, 1.0, 1.0), c, abs(t1 - t2) / maxDiff));
      
      if (absolute) {
        vertex(x1, y1);
        vertex(x2, y2);
      }
      else {
//        vertex(x1, Temp2Screen(tempMin) + (y1 - y2) / 2);
//        vertex(x2, Temp2Screen(tempMin) - (y1 - y2) / 2);
        vertex(x1, Temp2Screen(tempMin));
        vertex(x2, Temp2Screen(tempMin) - abs(y1 - y2));
      }
    }
    endShape(); 
  }
  
  private void DrawTempRange(List<Float> temp1, List<Float> temp2, color c) {      
    fill(c);
    noStroke();
//    stroke(c);
//    strokeWeight(1.0);
    
 
    beginShape(QUAD_STRIP);
    for (int i = viewMin; i <= viewMax; i++) {      
      float t1 = temp1.get(i);
      float t2 = temp2.get(i);
      
      // Hack to account for missing data
      if (t1 <= 0.0 || t2 <= 0.0) {
        endShape();
        beginShape(QUAD_STRIP);
        continue; 
      }
      
      float x1 = Step2Screen(i);
      float y1 = Temp2Screen(t1);
      
      float x2 = Step2Screen(i);
      float y2 = Temp2Screen(t2);
      
      vertex(x1, y1);
      vertex(x2, y2);
    }
    endShape(); 
  }
  
  private void DrawNormalizedRange(List<Float> n1, List<Float> n2, color c, float minVal, float maxVal) {       
    fill(c);
    noStroke();
//    stroke(c);
//    strokeWeight(1.0);
    
 
    beginShape(QUAD_STRIP);
    for (int i = viewMin; i <= viewMax; i++) {      
      float v1 = n1.get(i);
      float v2 = n2.get(i);
      
      // Hack to account for missing data
      if (v1 <= 0.0 || v2 <= 0.0) {
        endShape();
        beginShape(QUAD_STRIP);
        continue; 
      }
      
      float x1 = Step2Screen(i);
      float y1 = map(v1, minVal, maxVal, yMax * height, map(ySplit, 0.0, 1.0, yMin * height, yMax * height));
      
      float x2 = Step2Screen(i);
      float y2 = map(v2, minVal, maxVal, yMax * height, map(ySplit, 0.0, 1.0, yMin * height, yMax * height));
      
      vertex(x1, y1);
      vertex(x2, y2);
    }
    endShape(); 
  } 
  
  private void DrawXAxis(int numTicks) {
    fill(0.0, 0.0, 0.0);
    stroke(0.0, 0.0, 0.0);
    strokeWeight(2.0);
    
    line(width * xMin, height * yMax, width * xMax, height * yMax);
    
//    stroke(0.0, 0.0, 0.0, 0.25);
//    strokeWeight(2.0);
    line(width * xMin, map(ySplit, 0.0, 1.0, yMin * height, yMax * height), width * xMax, map(ySplit, 0.0, 1.0, yMin * height, yMax * height));
    
    textAlign(CENTER, TOP);
    int minTime = data.elapsedTime.get(viewMin);
    int maxTime = data.elapsedTime.get(viewMax);
    for (int i = 0; i < numTicks; i++) {
      int t = (int)(minTime + (maxTime - minTime) * float(i) / (numTicks - 1));
      text(t, width * (xMin + float(i) / (numTicks - 1) * (xMax - xMin)), height * (yMax + 0.02));    
    }
    
    text("Elapsed Time Since Birth (min)", width * (xMin + (xMax - xMin) * 0.5), height * (yMax + 0.06));
  }
  
  private void DrawYAxis(int numTicks) {
    stroke(0.0, 0.0, 0.0);
    fill(0.0, 0.0, 0.0);
    strokeWeight(2.0);
    
    line(width * xMin, height * yMin, width * xMin, map(ySplit, 0.0, 1.0, yMin * height, yMax * height));  
    
    textAlign(RIGHT, CENTER);
    for (int i = 0; i < numTicks; i++) {
      float t = tempMin + (tempMax - tempMin) * float(i) / (numTicks - 1);
      text(nf(t, 2, 1), (xMin - 0.01) * width, Temp2Screen(t));
    }
    
    pushMatrix();
    translate((xMin - 0.04) * width, (yMin + (yMax - yMin) * ySplit * 0.5) * height);
    rotate(-PI / 2.0);
    textAlign(CENTER, CENTER);
    text("Temperature (C)", 0, 0);
    popMatrix();
  }
  
  private void SetTemperatureRange() {
    // Initialize
    tempMin = tempMax = data.abdominalTemp.get(0);
    
    for (int i = 0; i < numValues; i++) {
      tempMin = min(tempMin, data.abdominalTemp.get(i));
      tempMin = min(tempMin, data.footTemp.get(i));
      tempMin = min(tempMin, data.externalTemp.get(i));
      tempMin = min(tempMin, data.servoTemp.get(i));
            
      tempMax = max(tempMax, data.abdominalTemp.get(i));
      tempMax = max(tempMax, data.footTemp.get(i));
      tempMax = max(tempMax, data.externalTemp.get(i));
      tempMax = max(tempMax, data.servoTemp.get(i));
    }
  }
  
  private float GetMaxDiff(List<Float> temp1, List<Float> temp2) {
    float maxDiff = 0.0;
    
    for (int i = 0; i < numValues; i++) {
      float t1 = temp1.get(i);
      float t2 = temp2.get(i);
      
      if (t1 <= 0.0 || t2 <= 0.0) {
        continue;
      } 
      
      maxDiff = max(maxDiff, abs(t1 - t2));
    }
    
    return maxDiff;
  }
  
  private float Temp2Screen(float temp) {
    return map(temp, tempMin, tempMax, map(ySplit, 0.0, 1.0, yMin * height, yMax * height), yMin * height);
  }
  
  private float Step2Screen(int i) {
    return map(i, viewMin, viewMax, xMin * width, xMax * width);
  }
  
  private int Mouse2Step(int x) {
    float v = ((float)x / width - xMin) / (xMax - xMin);
    v = min(v, 1.0);
    v = max(v, 0.0);
    
    return viewMin + (int)(v * (viewMax - viewMin));
  }
  
  void MousePressed() {    
    if (mouseX < xMin * width || mouseX > xMax * width ||
        mouseY < yMin * height || mouseY > yMax * height) {
      return; 
    }

    switch (mouseButton) {
     
      case LEFT:
        break;
       
      case RIGHT:             
        break;
    }
    
    oldMouseX = mouseX;
    oldMouseY = mouseY;    
    
    interact = true;
  }

  void MouseDragged() {
    if (!interact) {
      return; 
    }
    
    int deltaX = mouseX - oldMouseX;
    int deltaY = mouseY - oldMouseY;
    
    switch (mouseButton) {
      
      case LEFT:
        ScaleYAxis(deltaY);        
        break;
                     
      case RIGHT:
        Pan(deltaX);      
        break;
    }
                    
    oldMouseX = mouseX;
    oldMouseY = mouseY;
  }
  
  void MouseWheel(MouseEvent event) {
    Zoom(event.getAmount());
  }

  void MouseReleased() {
    interact = false;
  }
  
  void Pan(int panAmount) {
    float v = ((float)panAmount / width) / (xMax - xMin);   
    int dx = (int)(v * (viewMax - viewMin));
    
    viewMin += dx;
    viewMax += dx;
    
    if (viewMin < 0) {
      viewMax -= viewMin;
      viewMin = 0; 
    }
    if (viewMax > numValues - 1) {
      viewMin -= viewMax - (numValues - 1); 
      viewMax = numValues - 1;
    }
  }
  
  void Zoom(float zoomAmount) {
    zoomPoint = Mouse2Step(mouseX);
    
    int viewWidth = viewMax - viewMin - 1;
   
    if (zoomAmount < 0.0) {
      // Zoom in
      viewWidth /= 1.1 * -zoomAmount;
    }
    else {
      viewWidth *= 1.1 * zoomAmount;
    }
    
    viewWidth = max(viewWidth, 120);    
    
    float frac = (float)(zoomPoint - viewMin) / (viewMax - viewMin); 
  
    viewMin = zoomPoint - (int)(viewWidth * frac);
    viewMax = zoomPoint + (int)(viewWidth * (1.0 - frac));
  
    viewMin = max(viewMin, 0);
    viewMax = min(viewMax, numValues - 1);
    
//    data.SetKernelRadius((viewMax - viewMin) / 100);
  }
  
  void ScaleYAxis(int scaleAmount) { 
    ySplit += (float)scaleAmount / height; 
    ySplit = constrain(ySplit, 0.25, 1.0);
/*    
    float s = 0.001;
    
    yMin -= scaleAmount * s;
    yMax += scaleAmount * s;
    
    yMin = max(yMin, 0.1);
    yMin = min(yMin, 0.4);
    yMax = max(yMax, 0.6);
    yMax = min(yMax, 0.9);
*/
  }
}
