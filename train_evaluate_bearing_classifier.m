function results = train_evaluate_bearing_classifier(cfg, featureTable)
%TRAIN_EVALUATE_BEARING_CLASSIFIER Run report-ready classification tasks.

trainMask = featureTable.trial ~= 3;
testMask = featureTable.trial == 3;
trainTable = featureTable(trainMask, :);
testTable = featureTable(testMask, :);

results = struct();
results.trainWindowCount = height(trainTable);
results.testWindowCount = height(testTable);

% Main task: classify bearing health as healthy, inner fault, or outer fault.
healthFeatureNames = cfg.vibrationFeatureNames;
Xtrain = table2array(trainTable(:, healthFeatureNames));
Xtest = table2array(testTable(:, healthFeatureNames));
ytrain = trainTable.health_index;
ytest = testTable.health_index;
[XtrainZ, XtestZ, mu, sigma] = standardize_train_test(Xtrain, Xtest);

classIds = 1:numel(cfg.healthNames);
[predCentroid, centroids] = predict_nearest_centroid(XtrainZ, ytrain, XtestZ, classIds);
predKnn = predict_knn_plain(XtrainZ, ytrain, XtestZ, 5);

results.health.featureNames = healthFeatureNames;
results.health.standardizationMu = mu;
results.health.standardizationSigma = sigma;
results.health.centroids = centroids;
results.health.windowCentroidPred = predCentroid;
results.health.windowKnnPred = predKnn;
results.health.windowCentroidMetrics = compute_classification_metrics(ytest, predCentroid, classIds, cfg.healthNames);
results.health.windowKnnMetrics = compute_classification_metrics(ytest, predKnn, classIds, cfg.healthNames);
[results.health.fileKnnPredictions, results.health.fileKnnMetrics] = ...
    aggregate_file_predictions(testTable, predKnn, 'health_index', classIds, cfg.healthNames);

% Binary task: detect healthy versus faulty before diagnosis.
ytrainBinary = 1 + (trainTable.health_index ~= 1);
ytestBinary = 1 + (testTable.health_index ~= 1);
binaryNames = {'Healthy', 'Faulty'};
predBinary = predict_knn_plain(XtrainZ, ytrainBinary, XtestZ, 5);
results.faultDetection.windowPred = predBinary;
results.faultDetection.windowMetrics = compute_classification_metrics(ytestBinary, predBinary, 1:2, binaryNames);
[results.faultDetection.filePredictions, results.faultDetection.fileMetrics] = ...
    aggregate_file_predictions(replace_target_column(testTable, 'fault_target', ytestBinary), ...
    predBinary, 'fault_target', 1:2, binaryNames);

% Speed pattern classification from encoder-derived features.
speedFeatureNames = cfg.speedFeatureNames;
XtrainSpeed = table2array(trainTable(:, speedFeatureNames));
XtestSpeed = table2array(testTable(:, speedFeatureNames));
[XtrainSpeedZ, XtestSpeedZ] = standardize_train_test(XtrainSpeed, XtestSpeed);
predSpeed = predict_knn_plain(XtrainSpeedZ, trainTable.speed_index, XtestSpeedZ, 5);
results.speed.featureNames = speedFeatureNames;
results.speed.windowPred = predSpeed;
results.speed.windowMetrics = compute_classification_metrics(testTable.speed_index, predSpeed, 1:numel(cfg.speedNames), cfg.speedNames);
[results.speed.filePredictions, results.speed.fileMetrics] = ...
    aggregate_file_predictions(testTable, predSpeed, 'speed_index', 1:numel(cfg.speedNames), cfg.speedNames);

% Full 12-case task: health condition plus speed pattern.
caseNames = make_case_names(cfg);
XtrainCase = table2array(trainTable(:, cfg.featureNames));
XtestCase = table2array(testTable(:, cfg.featureNames));
[XtrainCaseZ, XtestCaseZ] = standardize_train_test(XtrainCase, XtestCase);
caseIds = 1:numel(caseNames);
predCase = predict_knn_plain(XtrainCaseZ, trainTable.case_index, XtestCaseZ, 5);
results.case.featureNames = cfg.featureNames;
results.case.windowPred = predCase;
results.case.windowMetrics = compute_classification_metrics(testTable.case_index, predCase, caseIds, caseNames);
[results.case.filePredictions, results.case.fileMetrics] = ...
    aggregate_file_predictions(testTable, predCase, 'case_index', caseIds, caseNames);

results.testTable = testTable;
end

function T = replace_target_column(T, targetName, values)
T.(targetName) = values;
end

function caseNames = make_case_names(cfg)
caseNames = cell(numel(cfg.healthNames) * numel(cfg.speedNames), 1);
idx = 0;
for h = 1:numel(cfg.healthCodes)
    for s = 1:numel(cfg.speedCodes)
        idx = idx + 1;
        caseNames{idx} = sprintf('%s-%s', cfg.healthCodes{h}, cfg.speedCodes{s});
    end
end
end
