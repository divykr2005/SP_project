function results = run_bearing_analysis()
%RUN_BEARING_ANALYSIS Reproduce the complete bearing analysis package.

cfg = bearing_config();
ensure_output_folders(cfg);

fprintf('\nBearing analysis started.\n');
fprintf('Project root: %s\n', cfg.projectRoot);
fprintf('Data folder: %s\n\n', cfg.dataFolder);

featurePath = fullfile(cfg.tableFolder, 'window_features.csv');
if exist(featurePath, 'file')
    fprintf('Loading cached window features: %s\n', featurePath);
    featureTable = readtable(featurePath, 'TextType', 'string');
else
    featureTable = extract_window_features(cfg);
    writetable(featureTable, featurePath);
end

summaryPath = fullfile(cfg.tableFolder, 'file_feature_summary.csv');
if exist(summaryPath, 'file')
    fprintf('Loading cached file summary: %s\n', summaryPath);
    fileSummary = readtable(summaryPath, 'TextType', 'string');
else
    fileSummary = summarize_file_features(featureTable, cfg);
    writetable(fileSummary, summaryPath);
end

figurePaths = strings(0, 1);
figurePaths = [figurePaths; make_speed_profile_plots(cfg)];
figurePaths = [figurePaths; make_signal_diagnostic_plots(cfg)];
figurePaths = [figurePaths; make_feature_summary_plots(cfg, featureTable, fileSummary)];

classification = train_evaluate_bearing_classifier(cfg, featureTable);
save(fullfile(cfg.modelFolder, 'plain_matlab_classification_results.mat'), ...
    'classification', 'cfg');
writetable(classification.health.fileKnnPredictions, ...
    fullfile(cfg.tableFolder, 'health_file_predictions.csv'));
writetable(classification.faultDetection.filePredictions, ...
    fullfile(cfg.tableFolder, 'fault_detection_file_predictions.csv'));
writetable(classification.speed.filePredictions, ...
    fullfile(cfg.tableFolder, 'speed_file_predictions.csv'));
writetable(classification.case.filePredictions, ...
    fullfile(cfg.tableFolder, 'case12_file_predictions.csv'));
figurePaths = [figurePaths; make_classification_plots(cfg, classification)];

severity = compute_severity_index(cfg, featureTable);
writetable(severity.windowTable, fullfile(cfg.tableFolder, 'window_severity_scores.csv'));
writetable(severity.fileTable, fullfile(cfg.tableFolder, 'file_severity_scores.csv'));
figurePaths = [figurePaths; make_severity_plots(cfg, severity)];

reportPath = write_bearing_report(cfg, featureTable, fileSummary, classification, severity, figurePaths);

results = struct();
results.cfg = cfg;
results.featureTable = featureTable;
results.fileSummary = fileSummary;
results.classification = classification;
results.severity = severity;
results.figurePaths = figurePaths;
results.reportPath = reportPath;

save(fullfile(cfg.outputFolder, 'bearing_analysis_results.mat'), 'results', '-v7.3');

fprintf('\nBearing analysis complete.\n');
fprintf('Report: %s\n', reportPath);
fprintf('Tables: %s\n', cfg.tableFolder);
fprintf('Figures: %s\n', cfg.figureFolder);
end
