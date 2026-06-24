# Moran’s I on Residuals from a Spatial Regression Model

## Project Overview

This project evaluates whether the residuals from a spatial regression model are spatially autocorrelated. Using weather-station data and raster-based predictor layers, a regression model was fitted on a calibration sample, validated on a hold-out sample, and then assessed with Moran’s I on the validation residuals. The workflow also includes spatial prediction over the raster layers.

## Objectives

- Retrieve predictor information from spatial layers.
- Split the dataset into calibration (75%) and validation (25%) samples.
- Fit a spatial regression model.
- Predict the validation sample.
- Calculate validation residuals.
- Test residual spatial autocorrelation using Moran’s I.

## Data

- `weather_stations.shp` — point layer of weather stations.
- Raster predictor layers from the weather variable folder.
- `T_AVG` — response variable used in the regression model.

## Methodology

### Data Preparation
- Loaded the weather-station point layer.
- Extracted coordinates from the station locations.
- Loaded raster predictor layers and extracted values at the station points.

### Model Fitting
- Built a regression dataset combining the response variable and raster-derived predictors.
- Split the dataset into calibration and validation samples using a 75/25 split.
- Fitted a linear regression model on the calibration sample.

### Validation
- Predicted values for the validation sample.
- Computed residuals as observed minus predicted values.
- Calculated RMSE for model evaluation.

### Spatial Autocorrelation Test
- Constructed an inverse-distance weight matrix from validation-point coordinates.
- Applied Moran’s I to the validation residuals to test for spatial autocorrelation.

### Spatial Prediction
- Generated a spatial prediction raster from the fitted model.
- Saved the prediction as a raster output.

## Main Outputs

- Fitted spatial regression model
- Validation residuals
- RMSE
- Moran’s I statistic for residuals
- Spatial prediction raster

## Skills Demonstrated

- Spatial data handling in R
- Raster extraction
- Regression modelling
- Train-validation splitting
- Prediction and residual analysis
- Spatial autocorrelation testing with Moran’s I
- Raster prediction mapping


## CV Bullet

Fitted and validated a spatial regression model in R using raster predictors, then assessed spatial autocorrelation in validation residuals with Moran’s I.
