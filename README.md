# HydroSatML
## Capstone Project - UW Data Science Master's Program


### Abstract

Soil moisture is an important characteristic in agriculture as it has been shown to correlate strongly with
plant health and crop yields. However, accurate soil moisture readings can only be obtained in-situ. Such measurements
are expensive and impractical for capturing high-resolution variability in soil moisture at scale. Remote sensing offers
the promise of low cost measurements with high temporal and spatial resolution; however, there is currently no 
established method to leverage remote sensing, e.g. satellite imagery, to obtain accurate soil moisture values
at scale.

We developed machine learning models that use high-resolution multispectral satellite imagery from Planet Labs, Inc. 
to predict soil moisture in the Palouse region of Washington and Idaho. Our goal was to create a tool that provides 
farmers with useful insight into their fields’ soil moisture at a scale, frequency and resolution that would otherwise
be prohibitively expensive to achieve with today’s technology.  In addition and as an extension to this project, 
we have developed a time-series model for pre-plant soil moisture prediction.

<reference to Project Proposal>


### Background

Our project was sponsored by the Crop and Soil Sciences Department at Washington State University and the Department of 
Soil and Water Systems at University of Idaho.

We obtained all relevant data from the sponsor as listed below:

### Data

Features:
 - Spectral satellite image data obtained from Planet Labs
 - Weather data - temperature, humidity, wind, etc.
 - Soil Properties - percentages of clay, silt, sand
 
Response:
 - Soil Moisture collected from sensors (from sensors)


### Directory Structure
```
HydroSatML/
  |- data/
  |- journal_articles/
  |- jupyter_notebooks/
  |- R_scripts/
       |- NDRE_exploration.R
       |- SMR Extraction and Comparison.R
       |- hydrosatML_result_plots.R
       |- kriging.R
       |- lagged_df_function.R
       |- merge_data.R
       |- merge_data_script.R
       |- plot_all_NDRE.R
       |- soilM_precision_maps.R
       |- subset_ndre_byShape.R
       |- time_series_data.R
  |- SMR/
  |- LICENSE     
  |- README.md
  |- interpolation.pptx
  |- latlongs.pptx

```

### Acknowledgements


A thanks to our sponsors:

- Matt Yourek - PhD student,  Washington State University, Department of Civil and Environmental Engineering
- Dr. David Brown - Professor, Washington State University, Department of Crop and Soil Sciences
- Dr. Erin Brooks - Professor, University of Idaho, Department of Soil and Water Systems  

And our project advisor:
- Dr. Megan Hazen - University of Washington, Data Science Capstone
