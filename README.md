# Bearing Fault Diagnosis Under Time-Varying Rotational Speed

## Objective

This report analyzes vibration and encoder signals from 36 bearing datasets. The goal is condition monitoring and fault diagnosis under non-stationary speed conditions. The valid supervised target is bearing health class: healthy, inner race fault, or outer race fault. A relative severity index is also included, but it is not a ground-truth damage-size label.

## Dataset

- Files: 36 `.mat` datasets
- Channels: `Channel_1` vibration, `Channel_2` encoder speed
- Sampling rate: 200000 Hz
- Duration per file: 10 seconds
- Window length: 0.10 seconds with 50% overlap
- Extracted windows: 7164

Filename format: `Health-Speed-Trial.mat`, for example `I-C-2.mat` means inner race fault, increasing then decreasing speed, trial 2.

## Signal Analysis Outputs

The workflow generates speed profiles, waveform comparisons, manual spectrograms, envelope spectra, and approximate order spectra. Order tracking is important because fault signatures can smear in a normal FFT when rotational speed changes over time.

## Feature Summary

The table below uses file-level means from all 36 datasets.

| Health class | RMS mean | Kurtosis mean | Crest factor mean |
|---|---:|---:|---:|
| Healthy | 0.00811191 | 5.54245 | 9.31156 |
| Inner race fault | 0.0444381 | 14.3141 | 10.2471 |
| Outer race fault | 0.00887814 | 6.00518 | 8.49949 |

Inner race fault files show much higher RMS and kurtosis than healthy files, with additional separation visible in the other extracted features. Outer race faults are closer to healthy in simple time-domain features, so frequency, envelope, and order-domain views are useful.

## Classification Results

Training used trials 1 and 2. Testing used trial 3, which avoids random-window leakage from the same experiment.

| Task | Level | Accuracy | Macro F1 |
|---|---|---:|---:|
| Healthy vs inner vs outer | Window | 98.99% | 0.990 |
| Healthy vs inner vs outer | File | 100.00% | 1.000 |
| Healthy vs faulty | Window | 98.99% | 0.989 |
| Healthy vs faulty | File | 100.00% | 1.000 |
| Speed pattern A/B/C/D | File | 75.00% | 0.754 |
| 12 combined cases | File | 83.33% | 0.778 |

### File-Level Health Predictions

| file | true name | predicted name | correct |
|---|---|---|---:|
| H-A-3.mat | Healthy | Healthy | true |
| H-B-3.mat | Healthy | Healthy | true |
| H-C-3.mat | Healthy | Healthy | true |
| H-D-3.mat | Healthy | Healthy | true |
| I-A-3.mat | Inner race fault | Inner race fault | true |
| I-B-3.mat | Inner race fault | Inner race fault | true |
| I-C-3.mat | Inner race fault | Inner race fault | true |
| I-D-3.mat | Inner race fault | Inner race fault | true |
| O-A-3.mat | Outer race fault | Outer race fault | true |
| O-B-3.mat | Outer race fault | Outer race fault | true |
| O-C-3.mat | Outer race fault | Outer race fault | true |
| O-D-3.mat | Outer race fault | Outer race fault | true |

## Relative Severity Index

The dataset has no explicit mild/severe defect labels. Therefore, the severity level below is an estimated abnormality score based on normalized RMS, peak-to-peak, crest factor, kurtosis, energy, spectral energy, high-frequency ratio, and speed-normalized RMS. Healthy files define the baseline.

- Good threshold: 0.7772
- Severe threshold: 10.83

These thresholds support report discussion, but they should not be presented as physical crack-depth or defect-size labels.

### File-Level Estimated Severity

| file | health name | speed name | severity score | estimated level |
|---|---|---|---:|---|
| H-A-1.mat | Healthy | Increasing speed | 0.17087 | Good/normal |
| H-A-2.mat | Healthy | Increasing speed | 0.40672 | Good/normal |
| H-A-3.mat | Healthy | Increasing speed | 0.28495 | Good/normal |
| H-B-1.mat | Healthy | Decreasing speed | 0.42912 | Good/normal |
| H-B-2.mat | Healthy | Decreasing speed | 0.44105 | Good/normal |
| H-B-3.mat | Healthy | Decreasing speed | 0.49328 | Good/normal |
| H-C-1.mat | Healthy | Increasing then decreasing speed | 0.27998 | Good/normal |
| H-C-2.mat | Healthy | Increasing then decreasing speed | 0.20811 | Good/normal |
| H-C-3.mat | Healthy | Increasing then decreasing speed | 0.17079 | Good/normal |
| H-D-1.mat | Healthy | Decreasing then increasing speed | 0.18304 | Good/normal |
| H-D-2.mat | Healthy | Decreasing then increasing speed | 0.24612 | Good/normal |
| H-D-3.mat | Healthy | Decreasing then increasing speed | 1.1243 | Mild abnormal |
| I-A-1.mat | Inner race fault | Increasing speed | 26.57 | Severe abnormal |
| I-A-2.mat | Inner race fault | Increasing speed | 29.581 | Severe abnormal |
| I-A-3.mat | Inner race fault | Increasing speed | 29.134 | Severe abnormal |
| I-B-1.mat | Inner race fault | Decreasing speed | 20.289 | Severe abnormal |
| I-B-2.mat | Inner race fault | Decreasing speed | 26.606 | Severe abnormal |
| I-B-3.mat | Inner race fault | Decreasing speed | 31.985 | Severe abnormal |
| I-C-1.mat | Inner race fault | Increasing then decreasing speed | 32.905 | Severe abnormal |
| I-C-2.mat | Inner race fault | Increasing then decreasing speed | 29.147 | Severe abnormal |
| I-C-3.mat | Inner race fault | Increasing then decreasing speed | 21.585 | Severe abnormal |
| I-D-1.mat | Inner race fault | Decreasing then increasing speed | 30.211 | Severe abnormal |
| I-D-2.mat | Inner race fault | Decreasing then increasing speed | 30.306 | Severe abnormal |
| I-D-3.mat | Inner race fault | Decreasing then increasing speed | 30.72 | Severe abnormal |
| O-A-1.mat | Outer race fault | Increasing speed | 1.319 | Mild abnormal |
| O-A-2.mat | Outer race fault | Increasing speed | 1.2761 | Mild abnormal |
| O-A-3.mat | Outer race fault | Increasing speed | 1.1148 | Mild abnormal |
| O-B-1.mat | Outer race fault | Decreasing speed | 1.1312 | Mild abnormal |
| O-B-2.mat | Outer race fault | Decreasing speed | 1.2418 | Mild abnormal |
| O-B-3.mat | Outer race fault | Decreasing speed | 1.3134 | Mild abnormal |
| O-C-1.mat | Outer race fault | Increasing then decreasing speed | 0.86917 | Mild abnormal |
| O-C-2.mat | Outer race fault | Increasing then decreasing speed | 1.0327 | Mild abnormal |
| O-C-3.mat | Outer race fault | Increasing then decreasing speed | 0.95044 | Mild abnormal |
| O-D-1.mat | Outer race fault | Decreasing then increasing speed | 1.3622 | Mild abnormal |
| O-D-2.mat | Outer race fault | Decreasing then increasing speed | 1.0465 | Mild abnormal |
| O-D-3.mat | Outer race fault | Decreasing then increasing speed | 1.024 | Mild abnormal |

## Generated Figures

- [speed_profiles_trial3.png](../figures/speed_profiles_trial3.png)
- [waveform_comparison_ha_ia_oa.png](../figures/waveform_comparison_ha_ia_oa.png)
- [spectrogram_h-a-3.png](../figures/spectrogram_h-a-3.png)
- [envelope_spectrum_h-a-3.png](../figures/envelope_spectrum_h-a-3.png)
- [order_spectrum_h-a-3.png](../figures/order_spectrum_h-a-3.png)
- [spectrogram_i-a-3.png](../figures/spectrogram_i-a-3.png)
- [envelope_spectrum_i-a-3.png](../figures/envelope_spectrum_i-a-3.png)
- [order_spectrum_i-a-3.png](../figures/order_spectrum_i-a-3.png)
- [spectrogram_o-a-3.png](../figures/spectrogram_o-a-3.png)
- [envelope_spectrum_o-a-3.png](../figures/envelope_spectrum_o-a-3.png)
- [order_spectrum_o-a-3.png](../figures/order_spectrum_o-a-3.png)
- [feature_summary_by_health.png](../figures/feature_summary_by_health.png)
- [feature_separation_scores.png](../figures/feature_separation_scores.png)
- [confusion_health_window_knn.png](../figures/confusion_health_window_knn.png)
- [confusion_health_file_knn.png](../figures/confusion_health_file_knn.png)
- [confusion_speed_file_knn.png](../figures/confusion_speed_file_knn.png)
- [confusion_12_case_file_knn.png](../figures/confusion_12_case_file_knn.png)
- [severity_score_by_file.png](../figures/severity_score_by_file.png)

## Limitations

This work should be described as bearing fault diagnosis or condition monitoring, not remaining useful life prediction. Predictive maintenance with future failure prediction would require time-ordered degradation data or known defect severity labels. The three trials in this dataset are repeat measurements, not mild, moderate, and severe damage stages.

## Conclusion

The dataset supports classification of healthy, inner race fault, and outer race fault bearings under variable speed. Window-based feature extraction reduces the raw signals to compact diagnostic descriptors, while speed profiles, spectrograms, envelope spectra, and order spectra explain the non-stationary behavior. A relative health index can rank abnormality severity, but true mild/severe fault classification requires labeled severity data.
