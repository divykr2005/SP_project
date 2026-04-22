# Bearing Analysis Package

Run the complete workflow from MATLAB with:

```matlab
run('run_all_analysis.m')
```

The workflow uses only base MATLAB functions. It avoids Statistics and Signal Processing Toolbox dependencies by implementing the needed feature calculations, k-nearest-neighbor classifier, envelope extraction, spectrogram, and order spectrum manually.

## Main Outputs

- `outputs/report/Bearing_Analysis_Report.md` - final written report.
- `outputs/figures/` - speed profiles, waveforms, spectrograms, envelope spectra, order spectra, confusion matrices, and severity plot.
- `outputs/tables/window_features.csv` - extracted window-level features.
- `outputs/tables/file_feature_summary.csv` - one summarized feature row per `.mat` file.
- `outputs/tables/health_file_predictions.csv` - healthy / inner race / outer race predictions.
- `outputs/tables/fault_detection_file_predictions.csv` - healthy vs faulty predictions.
- `outputs/tables/speed_file_predictions.csv` - speed pattern predictions.
- `outputs/tables/case12_file_predictions.csv` - combined health-speed case predictions.
- `outputs/tables/file_severity_scores.csv` - estimated relative severity scores.
- `outputs/models/plain_matlab_classification_results.mat` - saved classification result structure.

## Important Interpretation

The dataset supports bearing fault diagnosis:

- Healthy
- Inner race fault
- Outer race fault

The dataset does not contain true defect-size labels, so mild/severe condition levels are estimated from a relative vibration health index. They should be reported as abnormality levels, not physical crack depth or remaining useful life.
