# HydroSatML
**Capstone Project - UW Data Science Masters Program**  
*Dane Jordan, Samir Patel, Rex Thompson, Michael Grant*

## Overview

Soil moisture is an important characteristic in agriculture as it has been shown to correlate strongly with plant health and crop yields. However, accurate soil moisture readings are expensive and impractical for capturing high-resolution variability in soil moisture at scale. Remote sensing (e.g. satellite imagery) offers a potential low-cost solution.

Our objective was to determine whether machine learning models can be used to accurately estimate soil moisture with high-resolution multispectral satellite imagery, physical characteristics and environmental factors.

The project and results are summarized in the poster below.

![Alt text](/presentations/images/MSDS_Capstone_Poster_FINAL.png "Final Poster")

## Project Structure

### Overview

```
HydroSatML/
	|- code/
		|- 1_cleaning_and_merging
		|- 2_utilities
		|- 3_modeling
		|- 4_supplementals
	|- data/
		|- best_params
		|- figures
		|- models
	|- presentations/
		|- images
	|- LICENSE
	|- README.md
```

### Data

We gathered data from four fields in Eastern Washington and Western Idaho during the 2012-2014 growing seasons:

**Features:**
 * Multispectral satellite imagery obtained from Planet Labs
 * Weather data - temperature, humidity, wind, etc.
 * Soil Properties - percentages of clay, silt, sand

**Response:**
 * Soil Moisture collected from sensors

Unfortunately our data is not publicly available, and therefore it is not included within this repository.

### Code

The code is organized in the following main directories:

* **Data Cleaning and Merging:** Tools to clean and merge the raw data
* **Modeling:** Machine learning models for estimating soil moisture
* **Utilities:** Various utilities used throughout this project

## Results

### Satellite-based Modeling

We used an XGBoost model which yielded a Mean Absolute Error (MAE) of 0.027; this is an improvement over the results obtained from the physical Soil Moisture Routing (SMR) model, which yielded a MAE of 0.035.

### Bare Soil Predictions
To estimate soil moisture in the absence of vegetation, we trained a convolutional neural
network (CNN) using the physical characteristics of the soil and weather data. We extended this
model to yield two-week soil moisture forecasts. The CNN model yielded a MAE of 0.043.

## Future Work

### Physical Model and Interpolation

A physical (hydrological) model could be utilized to estimate soil moisture beyond the 12 sensor locations. While less precise, a kriging or splining method could be used to spatially interpolate soil moisture across the fields where no vegetation or soil moisture readings are present.

### Beyond the Palouse

It is unclear how our models would perform for fields beyond the Palouse. To develop a more robust model, future work would benefit from new training data encompassing a wider range of physical characteristics.

## Acknowledgements

Our project was sponsored by the Washington State University's Department of Crop and Soil Sciences and the University of Idaho's Department of Soil and Water Systems.

A thanks to our sponsors:

- **Matt Yourek** - PhD student, Washington State University, Department of Civil & Environmental Engineering
- **Dr. David Brown** - Professor, Washington State University, Department of Crop and Soil Sciences
- **Dr. Erin Brooks** - Professor, University of Idaho, Department of Soil and Water Systems  

And our project advisor:
- **Dr. Megan Hazen** - University of Washington, Data Science Capstone

## License

The code in this repository is released under the MIT license.