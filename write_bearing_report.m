function reportPath = write_bearing_report(cfg, featureTable, fileSummary, classification, severity, figurePaths)
%WRITE_BEARING_REPORT Write a Markdown report with generated results.

reportPath = fullfile(cfg.reportFolder, 'Bearing_Analysis_Report.md');
fid = fopen(reportPath, 'w');
if fid < 0
    error('Could not write report: %s', reportPath);
end
cleanup = onCleanup(@() fclose(fid));

fprintf(fid, '# Bearing Fault Diagnosis Under Time-Varying Rotational Speed\n\n');
fprintf(fid, '## Objective\n\n');
fprintf(fid, ['This report analyzes vibration and encoder signals from 36 bearing datasets. ', ...
    'The goal is condition monitoring and fault diagnosis under non-stationary speed conditions. ', ...
    'The valid supervised target is bearing health class: healthy, inner race fault, or outer race fault. ', ...
    'A relative severity index is also included, but it is not a ground-truth damage-size label.\n\n']);

fprintf(fid, '## Dataset\n\n');
fprintf(fid, '- Files: %d `.mat` datasets\n', numel(unique(featureTable.file)));
fprintf(fid, '- Channels: `Channel_1` vibration, `Channel_2` encoder speed\n');
fprintf(fid, '- Sampling rate: %d Hz\n', cfg.fs);
fprintf(fid, '- Duration per file: %g seconds\n', cfg.durationSeconds);
fprintf(fid, '- Window length: %.2f seconds with %.0f%% overlap\n', cfg.windowSeconds, cfg.overlap * 100);
fprintf(fid, '- Extracted windows: %d\n\n', height(featureTable));

fprintf(fid, 'Filename format: `Health-Speed-Trial.mat`, for example `I-C-2.mat` means inner race fault, increasing then decreasing speed, trial 2.\n\n');

fprintf(fid, '## Signal Analysis Outputs\n\n');
fprintf(fid, 'The workflow generates speed profiles, waveform comparisons, manual spectrograms, envelope spectra, and approximate order spectra. ');
fprintf(fid, 'Order tracking is important because fault signatures can smear in a normal FFT when rotational speed changes over time.\n\n');

fprintf(fid, '## Feature Summary\n\n');
fprintf(fid, 'The table below uses file-level means from all 36 datasets.\n\n');
fprintf(fid, '| Health class | RMS mean | Kurtosis mean | Crest factor mean |\n');
fprintf(fid, '|---|---:|---:|---:|\n');
for h = 1:numel(cfg.healthNames)
    mask = fileSummary.health_index == h;
    fprintf(fid, '| %s | %.6g | %.6g | %.6g |\n', ...
        cfg.healthNames{h}, ...
        mean(fileSummary.rms_value_mean(mask)), ...
        mean(fileSummary.kurtosis_value_mean(mask)), ...
        mean(fileSummary.crest_factor_mean(mask)));
end
fprintf(fid, '\n');

fprintf(fid, 'Inner race fault files show much higher RMS and kurtosis than healthy files, with additional separation visible in the other extracted features. ');
fprintf(fid, 'Outer race faults are closer to healthy in simple time-domain features, so frequency, envelope, and order-domain views are useful.\n\n');

fprintf(fid, '## Classification Results\n\n');
fprintf(fid, 'Training used trials 1 and 2. Testing used trial 3, which avoids random-window leakage from the same experiment.\n\n');
fprintf(fid, '| Task | Level | Accuracy | Macro F1 |\n');
fprintf(fid, '|---|---|---:|---:|\n');
fprintf(fid, '| Healthy vs inner vs outer | Window | %.2f%% | %.3f |\n', ...
    100 * classification.health.windowKnnMetrics.accuracy, classification.health.windowKnnMetrics.macroF1);
fprintf(fid, '| Healthy vs inner vs outer | File | %.2f%% | %.3f |\n', ...
    100 * classification.health.fileKnnMetrics.accuracy, classification.health.fileKnnMetrics.macroF1);
fprintf(fid, '| Healthy vs faulty | Window | %.2f%% | %.3f |\n', ...
    100 * classification.faultDetection.windowMetrics.accuracy, classification.faultDetection.windowMetrics.macroF1);
fprintf(fid, '| Healthy vs faulty | File | %.2f%% | %.3f |\n', ...
    100 * classification.faultDetection.fileMetrics.accuracy, classification.faultDetection.fileMetrics.macroF1);
fprintf(fid, '| Speed pattern A/B/C/D | File | %.2f%% | %.3f |\n', ...
    100 * classification.speed.fileMetrics.accuracy, classification.speed.fileMetrics.macroF1);
fprintf(fid, '| 12 combined cases | File | %.2f%% | %.3f |\n\n', ...
    100 * classification.case.fileMetrics.accuracy, classification.case.fileMetrics.macroF1);

fprintf(fid, '### File-Level Health Predictions\n\n');
write_markdown_table(fid, classification.health.fileKnnPredictions(:, {'file', 'true_name', 'predicted_name', 'correct'}));
fprintf(fid, '\n');

fprintf(fid, '## Relative Severity Index\n\n');
fprintf(fid, ['The dataset has no explicit mild/severe defect labels. ', ...
    'Therefore, the severity level below is an estimated abnormality score based on normalized RMS, peak-to-peak, crest factor, kurtosis, energy, spectral energy, high-frequency ratio, and speed-normalized RMS. ', ...
    'Healthy files define the baseline.\n\n']);
fprintf(fid, '- Good threshold: %.4g\n', severity.goodThreshold);
fprintf(fid, '- Severe threshold: %.4g\n\n', severity.severeThreshold);
fprintf(fid, 'These thresholds support report discussion, but they should not be presented as physical crack-depth or defect-size labels.\n\n');

fprintf(fid, '### File-Level Estimated Severity\n\n');
severityTable = severity.fileTable(:, {'file', 'health_name', 'speed_name', 'severity_score', 'estimated_level'});
write_markdown_table(fid, severityTable);
fprintf(fid, '\n');

fprintf(fid, '## Generated Figures\n\n');
for i = 1:numel(figurePaths)
    relPath = relative_report_path(cfg, char(figurePaths(i)));
    [~, name, ext] = fileparts(char(figurePaths(i)));
    fprintf(fid, '- [%s](%s)\n', [name, ext], relPath);
end
fprintf(fid, '\n');

fprintf(fid, '## Limitations\n\n');
fprintf(fid, ['This work should be described as bearing fault diagnosis or condition monitoring, not remaining useful life prediction. ', ...
    'Predictive maintenance with future failure prediction would require time-ordered degradation data or known defect severity labels. ', ...
    'The three trials in this dataset are repeat measurements, not mild, moderate, and severe damage stages.\n\n']);

fprintf(fid, '## Conclusion\n\n');
fprintf(fid, ['The dataset supports classification of healthy, inner race fault, and outer race fault bearings under variable speed. ', ...
    'Window-based feature extraction reduces the raw signals to compact diagnostic descriptors, while speed profiles, spectrograms, envelope spectra, and order spectra explain the non-stationary behavior. ', ...
    'A relative health index can rank abnormality severity, but true mild/severe fault classification requires labeled severity data.\n']);
end

function write_markdown_table(fid, T)
names = T.Properties.VariableNames;
fprintf(fid, '|');
for j = 1:numel(names)
    fprintf(fid, ' %s |', strrep(names{j}, '_', ' '));
end
fprintf(fid, '\n|');
for j = 1:numel(names)
    value = T.(names{j});
    if isnumeric(value) || islogical(value)
        fprintf(fid, '---:|');
    else
        fprintf(fid, '---|');
    end
end
fprintf(fid, '\n');

for i = 1:height(T)
    fprintf(fid, '|');
    for j = 1:numel(names)
        value = T.(names{j})(i);
        fprintf(fid, ' %s |', format_markdown_value(value));
    end
    fprintf(fid, '\n');
end
end

function text = format_markdown_value(value)
if isstring(value)
    text = char(value);
elseif iscell(value)
    text = char(string(value{1}));
elseif islogical(value)
    if value
        text = 'true';
    else
        text = 'false';
    end
elseif isnumeric(value)
    text = sprintf('%.5g', value);
else
    text = char(string(value));
end
text = strrep(text, '|', '/');
end

function rel = relative_report_path(cfg, targetPath)
targetPath = char(targetPath);
figureFolder = char(cfg.figureFolder);
tableFolder = char(cfg.tableFolder);

if startsWith(targetPath, figureFolder)
    [~, name, ext] = fileparts(targetPath);
    rel = ['../figures/', name, ext];
elseif startsWith(targetPath, tableFolder)
    [~, name, ext] = fileparts(targetPath);
    rel = ['../tables/', name, ext];
else
    rel = strrep(targetPath, '\', '/');
end
end
