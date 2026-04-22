function metrics = compute_classification_metrics(yTrue, yPred, classIds, classNames)
%COMPUTE_CLASSIFICATION_METRICS Confusion matrix and per-class scores.

confusion = zeros(numel(classIds));

for i = 1:numel(yTrue)
    trueIdx = find(classIds == yTrue(i), 1);
    predIdx = find(classIds == yPred(i), 1);
    if ~isempty(trueIdx) && ~isempty(predIdx)
        confusion(trueIdx, predIdx) = confusion(trueIdx, predIdx) + 1;
    end
end

accuracy = sum(diag(confusion)) / max(sum(confusion(:)), 1);
precision = zeros(numel(classIds), 1);
recall = zeros(numel(classIds), 1);
f1 = zeros(numel(classIds), 1);

for i = 1:numel(classIds)
    precision(i) = confusion(i, i) / max(sum(confusion(:, i)), 1);
    recall(i) = confusion(i, i) / max(sum(confusion(i, :)), 1);
    f1(i) = 2 * precision(i) * recall(i) / max(precision(i) + recall(i), eps);
end

metrics = struct();
metrics.classIds = classIds(:);
metrics.classNames = string(classNames(:));
metrics.confusion = confusion;
metrics.accuracy = accuracy;
metrics.precision = precision;
metrics.recall = recall;
metrics.f1 = f1;
metrics.macroF1 = mean(f1);
end
