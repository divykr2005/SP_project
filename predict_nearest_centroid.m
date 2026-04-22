function [predicted, centroids] = predict_nearest_centroid(Xtrain, ytrain, Xtest, classIds)
%PREDICT_NEAREST_CENTROID Plain MATLAB nearest-centroid classifier.

centroids = zeros(numel(classIds), size(Xtrain, 2));
for i = 1:numel(classIds)
    centroids(i, :) = mean(Xtrain(ytrain == classIds(i), :), 1);
end

distances = zeros(size(Xtest, 1), numel(classIds));
for i = 1:numel(classIds)
    diff = Xtest - centroids(i, :);
    distances(:, i) = sum(diff .^ 2, 2);
end

[~, idx] = min(distances, [], 2);
predicted = classIds(idx(:));
end
