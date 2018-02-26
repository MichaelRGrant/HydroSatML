# HydroSatML
## Capstone Project - UW Data Science Master's Program


### Abstract:

Soil moisture is an important characteristic in agriculture as it has been shown to correlate strongly with
plant health and crop yields. However, accurate soil moisture readings can only be obtained in-situ. Such measurements
are expensive and impractical for capturing high-resolution variability in soil moisture at scale. Remote sensing offers
the promise of low cost measurements with high temporal and spatial resolution; however, there is currently no 
established method to leverage remote sensing, e.g. satellite imagery, to obtain accurate soil moisture values
at scale.

We developed machine learning models that use high-resolution multispectral satellite imagery from Planet Labs, Inc. 
to predict soil moisture in the Palouse region of Washington and Idaho. Our goal was to create a tool that provides 
farmers with useful insight into their fields’ soil moisture at a scale, frequency and resolution that would otherwise
be prohibitively expensive to achieve with today’s technology.

<reference to Project Proposal>

### Background:

Our project was sponsored by the Soil Sciences Departments at Washington State University and the University of Idaho.  
We obtained all relevant data from the sponsor:

### Data:

Features:
 - Spectral satellite image data obtained from Planet Labs
 - Weather data - temperature, humidity, wind, etc.
 - Soil Properties - percentages of clay, silt, sand
 
Response:
 - Soil Moisture collected from sensors (from sensors)




### Objective:

Our goal was to produce a machine learning model that uses high-resolution multispectral satellite imagery to 
predict soil moisture at a sub-field level. The model was trained using in-situ soil moisture data and multispectral
satellite images. It  predicts soil moisture for different times/locations using additional multispectral satellite 
images.

In addition and as an extension to this project, we have developed a time-series model for pre-plant soil moisture 
prediction.

---

### Directory Structure
```
HydroSatML/
  |- data/
  |- journal_articles/
  |- jupyter_notebooks/
  |- R_scripts/
  |- SMR/
  |- LICENSE     
  |- README.md
```



---

