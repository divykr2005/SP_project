function featureTable = extract_window_features(cfg)
%EXTRACT_WINDOW_FEATURES Convert raw 2-channel files into window features.

files = dir(fullfile(cfg.dataFolder, '*.mat'));
[~, order] = sort({files.name});
files = files(order);

windowLength = round(cfg.windowSeconds * cfg.fs);
stepLength = round(windowLength * (1 - cfg.overlap));

estimatedRows = max(1, numel(files) * 250);
featureCount = numel(cfg.featureNames);

fileCol = strings(estimatedRows, 1);
baseNameCol = strings(estimatedRows, 1);
healthCodeCol = strings(estimatedRows, 1);
healthNameCol = strings(estimatedRows, 1);
speedCodeCol = strings(estimatedRows, 1);
speedNameCol = strings(estimatedRows, 1);
caseNameCol = strings(estimatedRows, 1);

healthIndexCol = zeros(estimatedRows, 1);
speedIndexCol = zeros(estimatedRows, 1);
caseIndexCol = zeros(estimatedRows, 1);
trialCol = zeros(estimatedRows, 1);
windowIndexCol = zeros(estimatedRows, 1);
windowStartCol = zeros(estimatedRows, 1);
windowEndCol = zeros(estimatedRows, 1);
featureValues = zeros(estimatedRows, featureCount);

row = 0;
for fileIndex = 1:numel(files)
    info = parse_bearing_filename(files(fileIndex).name, cfg);
    fprintf('Extracting window features from %s\n', files(fileIndex).name);

    S = load(fullfile(files(fileIndex).folder, files(fileIndex).name));
    vib = S.Channel_1(:);
    speed = S.Channel_2(:);
    sampleCount = numel(vib);
    starts = 1:stepLength:(sampleCount - windowLength + 1);

    for w = 1:numel(starts)
        row = row + 1;
        if row > size(featureValues, 1)
            growBy = estimatedRows;
            fileCol(end+growBy, 1) = "";
            baseNameCol(end+growBy, 1) = "";
            healthCodeCol(end+growBy, 1) = "";
            healthNameCol(end+growBy, 1) = "";
            speedCodeCol(end+growBy, 1) = "";
            speedNameCol(end+growBy, 1) = "";
            caseNameCol(end+growBy, 1) = "";
            healthIndexCol(end+growBy, 1) = 0;
            speedIndexCol(end+growBy, 1) = 0;
            caseIndexCol(end+growBy, 1) = 0;
            trialCol(end+growBy, 1) = 0;
            windowIndexCol(end+growBy, 1) = 0;
            windowStartCol(end+growBy, 1) = 0;
            windowEndCol(end+growBy, 1) = 0;
            featureValues(end+growBy, featureCount) = 0;
        end

        idx = starts(w):(starts(w) + windowLength - 1);
        featureValues(row, :) = compute_bearing_features(vib(idx), speed(idx), cfg.fs);

        fileCol(row) = info.file;
        baseNameCol(row) = info.baseName;
        healthCodeCol(row) = info.healthCode;
        healthNameCol(row) = info.healthName;
        speedCodeCol(row) = info.speedCode;
        speedNameCol(row) = info.speedName;
        caseNameCol(row) = info.caseName;
        healthIndexCol(row) = info.healthIndex;
        speedIndexCol(row) = info.speedIndex;
        caseIndexCol(row) = info.caseIndex;
        trialCol(row) = info.trial;
        windowIndexCol(row) = w;
        windowStartCol(row) = (starts(w) - 1) / cfg.fs;
        windowEndCol(row) = (starts(w) + windowLength - 2) / cfg.fs;
    end
end

fileCol = fileCol(1:row);
baseNameCol = baseNameCol(1:row);
healthCodeCol = healthCodeCol(1:row);
healthNameCol = healthNameCol(1:row);
speedCodeCol = speedCodeCol(1:row);
speedNameCol = speedNameCol(1:row);
caseNameCol = caseNameCol(1:row);
healthIndexCol = healthIndexCol(1:row);
speedIndexCol = speedIndexCol(1:row);
caseIndexCol = caseIndexCol(1:row);
trialCol = trialCol(1:row);
windowIndexCol = windowIndexCol(1:row);
windowStartCol = windowStartCol(1:row);
windowEndCol = windowEndCol(1:row);
featureValues = featureValues(1:row, :);

featureTable = table( ...
    fileCol, ...
    baseNameCol, ...
    healthCodeCol, ...
    healthIndexCol, ...
    healthNameCol, ...
    speedCodeCol, ...
    speedIndexCol, ...
    speedNameCol, ...
    caseIndexCol, ...
    caseNameCol, ...
    trialCol, ...
    windowIndexCol, ...
    windowStartCol, ...
    windowEndCol, ...
    'VariableNames', { ...
    'file', ...
    'base_name', ...
    'health_code', ...
    'health_index', ...
    'health_name', ...
    'speed_code', ...
    'speed_index', ...
    'speed_name', ...
    'case_index', ...
    'case_name', ...
    'trial', ...
    'window_index', ...
    'window_start_sec', ...
    'window_end_sec'});

for j = 1:featureCount
    featureTable.(cfg.featureNames{j}) = featureValues(:, j);
end
end
