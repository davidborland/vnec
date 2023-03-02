/*=========================================================================
 
 Name:        vnec.pde
 
 Author:      David Borland, The Renaissance Computing Institute (RENCI)
 
 Copyright:   The Renaissance Computing Institute (RENCI)
 
 Description: PatientData loads time series data of pediatric nec patients
              from a csv file.
 
=========================================================================*/


// XXX: Need to create generic class for holding individual data arrays


class PatientData {    
  // Time data
  List<String> date;
  List<String> time;
  List<Integer> elapsedTime;
  List<Integer> day;
  
  // Temperature data
  List<Float> abdominalTemp;
  List<Float> footTemp;
  List<Float> externalTemp;
  List<Float> servoTemp;
  List<Float> deltaTemp;
  
  List<Float> abdominalMin;
  List<Float> abdominalMax;
  
  List<Float> footMin;
  List<Float> footMax;
  
  List<Float> externalMin;
  List<Float> externalMax;
  
  // Circulation data
  List<Float> meanPI;
  List<Float> heartRate;
  
  List<Float> meanPIMin;
  List<Float> meanPIMax;
  
  List<Float> heartRateMin;
  List<Float> heartRateMax;
 
  // Area under the curve, per day
  List<Float> auc;
  
  // Other data codes
  List<List<String>> dataCodes;
  
  // Patient id
  String patient;
 
  PatientData() {
  } 
  
  void ReadData(String tempDataFileName, String dataCodesFileName) {
    ReadTempData(tempDataFileName);
    ReadDataCodes(dataCodesFileName);
  }
   
  void ReadTempData(String fileName) { 
    // Grab the patient id
    patient = fileName.substring(fileName.lastIndexOf("\\") + 1, fileName.lastIndexOf("."));
    
    // Create new data lists
    date = new ArrayList<String>();
    time = new ArrayList<String>();
    elapsedTime = new ArrayList<Integer>();
    day = new ArrayList<Integer>();
        
    abdominalTemp = new ArrayList<Float>();
    footTemp = new ArrayList<Float>();
    externalTemp = new ArrayList<Float>();
    servoTemp = new ArrayList<Float>();
    deltaTemp = new ArrayList<Float>();
        
    meanPI = new ArrayList<Float>();
    heartRate = new ArrayList<Float>();

    
    // Load the file into an array of strings
    String fileLines[] = loadStrings(fileName);
    
    // Create keys for map from column names.
    // Need to remove quotation marks, and then split on comma.
    String[] columns = split(fileLines[0].replace("\"", ""), ',');
    
    
    // Add the data
    for (int i = 1; i < fileLines.length; i++) {
      // Split the current line.
      // Need to remove quotation marks, and then split on comma.
      String line[] = split(fileLines[i].replace("\"", ""), ',');
      
      for (int j = 0; j < line.length; j++) {
        // Time data
        if (columns[j].equals("date")) {
          date.add(line[j]);
        }
        else if (columns[j].equals("time")) {
          time.add(line[j]);
        }
        else if (columns[j].equals("elapsedt")) {
          elapsedTime.add(Integer.parseInt(line[j]));
        }
        else if (columns[j].equals("day")) {
          day.add(Integer.parseInt(line[j])); 
        }
                
        // Temperature data
        else if (columns[j].equals("abdtp")) {
          abdominalTemp.add(Float.parseFloat(line[j]));
        }
        else if (columns[j].equals("fttp")) {
          footTemp.add(Float.parseFloat(line[j]));
        }
        else if (columns[j].equals("exttp")) {
          externalTemp.add(Float.parseFloat(line[j]));
        }
        else if (columns[j].equals("tempisc")) {
          servoTemp.add(Float.parseFloat(line[j]));
        }
        else if (columns[j].equals("afdeltat")) {
          deltaTemp.add(Float.parseFloat(line[j]));
        }
        
        // Circulation data
        else if (columns[j].equals("meanpi")) {
          meanPI.add(Float.parseFloat(line[j]));
        }
        else if (columns[j].equals("hrge")) {
          heartRate.add(Float.parseFloat(line[j]));
        }
      }
    }
        
    // Create min and max arrays        
    abdominalMin = new ArrayList<Float>();
    abdominalMax = new ArrayList<Float>();
    
    footMin = new ArrayList<Float>();
    footMax = new ArrayList<Float>();
        
    externalMin = new ArrayList<Float>();
    externalMax = new ArrayList<Float>();
    
    meanPIMin = new ArrayList<Float>();
    meanPIMax = new ArrayList<Float>();
    
    heartRateMin = new ArrayList<Float>();
    heartRateMax = new ArrayList<Float>();
    
    for (int i = 0; i < externalTemp.size(); i++) {
      abdominalMin.add(0.0);
      abdominalMax.add(0.0);
      
      footMin.add(0.0);
      footMax.add(0.0);
      
      externalMin.add(0.0);
      externalMax.add(0.0);
      
      meanPIMin.add(0.0);
      meanPIMax.add(0.0);
      
      heartRateMin.add(0.0);
      heartRateMax.add(0.0);
    }
    
    SetKernelRadius(externalTemp.size() / 100);
  }
  
  void SetKernelRadius(int r) {
    SetKernelRadius(abdominalTemp, abdominalMin, abdominalMax, r);
    SetKernelRadius(footTemp, footMin, footMax, r);
    SetKernelRadius(externalTemp, externalMin, externalMax, r);
    SetKernelRadius(meanPI, meanPIMin, meanPIMax, r);
    SetKernelRadius(heartRate, heartRateMin, heartRateMax, r);
  }
  
  void SetKernelRadius(List<Float> array, List<Float> arrayMin, List<Float> arrayMax, int r) {    
    List<Float> aMax = new ArrayList<Float>();
    List<Float> aMin = new ArrayList<Float>();
    
    for (int i = 0; i < array.size(); i++) {
      float minVal = 1000.0;
      float maxVal = -1000.0;
      
      for (int j = -r; j <= r; j++) {
        int k = i + j;
        if (k < 0 || k >= array.size()) continue;
        
        float t = array.get(k);
        if (t <= 0.0) continue;
        
        minVal = min(minVal, t);
        maxVal = max(maxVal, t);
      }

      aMin.add(minVal);        
      aMax.add(maxVal); 
    }

    for (int i = 0; i < array.size(); i++) {
      if (aMin.get(i) > aMax.get(i)) {
        arrayMin.set(i, 0.0);
        arrayMax.set(i, 0.0);
        
        continue;
      }
            
      float minVal = 0.0;
      float maxVal = 0.0;
      int count = 0;
      
      for (int j = -r; j <= r; j++) {
        int k = i + j;
        if (k < 0 || k >= array.size()) continue;    
       
        if (aMin.get(k) > aMax.get(k)) continue;  
        
        minVal += aMin.get(k);
        maxVal += aMax.get(k);
        count++;
      }
      
      minVal /= count;
      maxVal /= count;
      
      arrayMin.set(i, minVal);
      arrayMax.set(i, maxVal);
    }   
  }
  
  void ReadDataCodes(String fileName) {
    auc = new ArrayList<Float>();
    dataCodes = new ArrayList<List<String>>();
    
    // Load the file into an array of strings
    String fileLines[] = loadStrings(fileName);
    
    // Create keys for map from column names.
    // Need to remove quotation marks, and then split on comma.
    String[] columns = split(fileLines[0].replace("\"", ""), ',');
    
    
    // Add the data
    for (int i = 2; i < fileLines.length; i++) {
      // Add list of strings
      dataCodes.add(new ArrayList<String>());
      
      // Split the current line.
      // Need to remove quotation marks, and then split on comma.
      String line[] = split(fileLines[i].replace("\"", ""), ',');
      
      // Skip first column
      for (int j = 1; j < line.length; j++) {
        if (columns[j].equals("AUC-I")) {
          auc.add(Float.parseFloat(line[j]));
        } 
        else {
          if (Integer.parseInt(line[j]) > 0) {
            dataCodes.get(dataCodes.size() - 1).add(columns[j]); 
          }
        }
      }
    }
  }
}
