function [filePredictionTable, metrics] = aggregate_file_predictions(testTable, yPred, targetColumn, classIds, classNames)
%AGGREGATE_FILE_PREDICTIONS Combine window predictions into file decisions.

files = unique(testTable.file, 'stable');
yTrueFile = zeros(numel(files), 1);
yPredFile = zeros(numel(files), 1);
fileCol = strings(numel(files), 1);
healthCol = strings(numel(files), 1);
speedCol = strings(numel(files), 1);
caseCol = strings(numel(files), 1);
predNameCol = strings(numel(files), 1);
trueNameCol = strings(numel(files), 1);

for i = 1:numel(files)
    mask = testTable.file == files(i);
    trueValues = testTable.(targetColumn)(mask);
    predValues = yPred(mask);
    yTrueFile(i) = majority_vote(trueValues);
    yPredFile(i) = majority_vote(predValues);

    fileCol(i) = files(i);
    first = find(mask, 1);
    healthCol(i) = testTable.health_name(first);
    speedCol(i) = testTable.speed_name(first);
    caseCol(i) = testTable.case_name(first);

    trueIdx = find(classIds == yTrueFile(i), 1);
    predIdx = find(classIds == yPredFile(i), 1);
    trueNameCol(i) = string(classNames{trueIdx});
    predNameCol(i) = string(classNames{predIdx});
end

filePredictionTable = table( ...
    fileCol, ...
    healthCol, ...
    speedCol, ...
    caseCol, ...
    yTrueFile, ...
    trueNameCol, ...
    yPredFile, ...
    predNameCol, ...
    yTrueFile == yPredFile, ...
    'VariableNames', { ...
    'file', ...
    'health_name', ...
    'speed_name', ...
    'case_name', ...
    'true_id', ...
    'true_name', ...
    'predicted_id', ...
    'predicted_name', ...
    'correct'});

metrics = compute_classification_metrics(yTrueFile, yPredFile, classIds, classNames);
end

function value = majority_vote(values)
ids = unique(values(:))';
counts = zeros(size(ids));
for i = 1:numel(ids)
    counts(i) = sum(values(:) == ids(i));
end
[~, best] = max(counts);
value = ids(best);
end
