# ==========================================================
# Moran's I on residuals from a spatial regression model
# ==========================================================

rm(list = ls())

# ----------------------------------------------------------
# 1. Load required packages
# ----------------------------------------------------------

library(sf)
library(terra)
library(ape)
library(tidyverse)

# ----------------------------------------------------------
# 2. Load weather station data
# ----------------------------------------------------------

# Read the point layer containing weather stations
wStation <- st_read("weather_stations.shp", quiet = TRUE) %>%
  drop_na()

# Extract coordinates from the spatial points
coords <- st_coordinates(wStation)

# Dependent variable
vdep <- wStation$T_AVG

# ----------------------------------------------------------
# 3. Load raster predictor layers
# ----------------------------------------------------------

# Load all raster layers from the folder
files <- list.files(
  "variable_weather",
  pattern = "\\.asc$",
  full.names = TRUE
)

rasters <- rast(files)

# Use file names as layer names
names(rasters) <- tools::file_path_sans_ext(basename(files))

# ----------------------------------------------------------
# 4. Extract raster values at station locations
# ----------------------------------------------------------

vindep <- terra::extract(rasters, coords)
vindep <- vindep[, -1]  # remove ID column

# Build modelling table with coordinates and predictors
regression <- data.frame(
  Tavg = vdep,
  x = coords[, 1],
  y = coords[, 2],
  vindep
)

# Remove missing values if any
regression <- na.omit(regression)

# ----------------------------------------------------------
# 5. Split data into calibration and validation samples
# ----------------------------------------------------------

set.seed(123)  # reproducibility

n <- nrow(regression)
cal_size <- floor(0.75 * n)

cal_index <- sample(seq_len(n), size = cal_size)

regression.cal <- regression[cal_index, ]
regression.val <- regression[-cal_index, ]

# ----------------------------------------------------------
# 6. Fit the spatial regression model
# ----------------------------------------------------------

# Fit the model using the calibration sample
# x and y are excluded because they are only needed for Moran's I
mod.lm <- lm(Tavg ~ . - x - y, data = regression.cal)

# Inspect model summary
summary(mod.lm)

# ----------------------------------------------------------
# 7. Predict on the validation sample
# ----------------------------------------------------------

pred.val <- predict(mod.lm, newdata = regression.val)

# Observed vs predicted values
obs.pred <- data.frame(
  OBS = regression.val$Tavg,
  PRED = pred.val
)

# Residuals on the validation sample
residuals.val <- obs.pred$OBS - obs.pred$PRED

# RMSE
rmse <- sqrt(mean(residuals.val^2))
rmse

# ----------------------------------------------------------
# 8. Compute Moran's I on validation residuals
# ----------------------------------------------------------

# Validation coordinates
coords.val <- as.matrix(regression.val[, c("x", "y")])

# Distance matrix
dists <- as.matrix(dist(coords.val))

# Inverse-distance weights
weights <- 1 / dists
diag(weights) <- 0
weights[is.infinite(weights)] <- 0

# Moran's I for residuals
moran_res <- Moran.I(residuals.val, weights)
moran_res

# ----------------------------------------------------------
# 9. Spatial prediction raster
# ----------------------------------------------------------

# Predict across the full raster stack
pred_map <- predict(rasters, mod.lm, na.rm = TRUE)

# Save output raster
writeRaster(pred_map, "spatial_regression_prediction.tif", overwrite = TRUE)

# Plot prediction
plot(pred_map, main = "Spatial Regression Prediction")
points(wStation, pch = 20, cex = 0.5)