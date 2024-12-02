
# Radar Data Dealiasing

This repository provides MATLAB scripts for radar data dealiasing, focusing on processing velocity (`vel`) and reflectivity (`dbz`) data. The main objective is to correct aliased velocity data caused by the Nyquist velocity limit, using algorithms techniques for post-processing.

![Doppler Velocity](https://github.com/i-samos/radar-data-dealising/blob/main/gifs/images.gif)

## Key Features
- **Dealiasing Algorithms**: Correct aliased velocity data caused by the Nyquist velocity limit.
- **Expansion and Filtering**: Includes neighborhood-based filtering and expansion algorithms for better continuity.
- **FFT Analysis**: Leverages FFT to identify and correct phase and amplitude inconsistencies.
- **Interactive Visualization**: Optional interactive mode for step-by-step visualization.
- **Comprehensive Functionality**: Modular functions for preprocessing, processing, and analysis.

---

## How It Works

### 1. **Aliased Velocity Data**
Aliased velocity occurs when radar measurements exceed the Nyquist limit, resulting in discontinuous sinusoidal patterns.

![Aliased Loop](https://github.com/i-samos/radar-data-dealising/blob/main/gifs/aliased.gif)

### 2. **Velocity Data de-aliasing**
Velocity Data is post processed through two (2) algorithms. The first is a collection of mathematical approaches, and the second is a geometrical approach.

![Expansion](https://github.com/i-samos/radar-data-dealising/blob/main/gifs/expansion.gif)

### 3. **Dealiased Velocity Data**
The dealiasing process corrects these patterns, restoring accurate velocity measurements.

![Dealiased Loop](https://github.com/i-samos/radar-data-dealising/blob/main/gifs/dealiased.gif)


---

## Repository Contents

### Main Script
- **`main_script.m`**: The main entry point for running the dealiasing workflow. It includes:
  - Initial preprocessing of radar data (`vel`, `dbz`, `lat`, `lon`, etc.).
  - Execution of the dealiasing algorithms (`dealise_velocities`).
  - Generation of plots and visualizations for aliased and dealiased velocities.

---

### Functions
#### Core Algorithms
- **`dealise_velocities.m`**: Combines mathematical and expansion algorithms for comprehensive dealiasing.
- **`dealise_filter.m`**: Applies initial sine-based dealiasing.
- **`correctAmplitude360Optimized.m`**: Corrects 360-degree amplitude wrapping to maintain phase continuity.
- **`deleted_rays.m`**: Identifies and removes problematic rays.

#### Filtering and Expansion
- **`speed.m`**: Filters reflectivity (`dbz`) based on velocity data (`vel`).
- **`box_filter.m`**: Applies a neighborhood-based filter to smooth velocity and reflectivity data.
- **`expansion_algorithm.m`**: Expands valid velocity regions into surrounding NaN areas.

#### Data Preparation and Reconstruction
- **`make_full.m`**: Fills gaps in the velocity field.
- **`locate_initial.m`**: Aligns the initial velocity profile for consistent reconstruction.
- **`calc_perimeters.m`**: Computes the perimeter of regions for velocity expansion.
- **`identifyBaselineRays.m`**: Identifies key rays for baseline corrections.

#### Auxiliary Functions
- **`sine_folding.m`**: Evaluates sine fitting and folding for dealiasing.
- **`sine_folding_results.m` / `sine_folding_results_plus90.m`**: Generates folded sine waves for comparison.
- **`eliminate_isolated.m`**: Removes isolated points in the velocity matrix.
- **`find_best_shift.m`**: Finds optimal shifts for aligning velocity data.

---

### Data Requirements
Example:
- `sample_data.mat`: Contains variables:
  - `vel`: Aliased velocity matrix.
  - `dbz`: Reflectivity matrix.
  - `lat`, `lon`: Latitude and longitude for visualization.
  - `Azimuth`, `Distance`, `Elevation`: Radar metadata.


---

## Usage

### Sample Input Data
Prepared radar data in `.mat` file:
```matlab
load('sample_data.mat');
```

### Run the Main Script
Execute the dealiasing workflow by running:
```matlab
main_script;
```

---

## Visualization
### Figures and Plots
The script generates visualizations for:
1. **Aliased Velocities**: Initial radar velocities with aliasing.
2. **Dealiased Velocities**: Corrected velocities using mathematical and expansion algorithms.
3. **Phases and Amplitudes**: Visual comparisons of FFT-derived phases and amplitudes.
4. **Step-by-Step Sine Visualization**: Interactive plots for analyzing aliased and dealiased sines row by row.


---

## Contribution
Feel free to contribute to this repository by:
- Improving the existing algorithms.
- Adding new features for enhanced dealiasing or visualization.
- Reporting issues or suggesting improvements.


