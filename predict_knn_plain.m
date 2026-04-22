function predicted = predict_knn_plain(Xtrain, ytrain, Xtest, k)
%PREDICT_KNN_PLAIN Small k-nearest-neighbor classifier without toolboxes.

classIds = unique(ytrain(:))';
predicted = zeros(size(Xtest, 1), 1);
batchSize = 250;

for first = 1:batchSize:size(Xtest, 1)
    last = min(first + batchSize - 1, size(Xtest, 1));
    Xbatch = Xtest(first:last, :);
    distances = zeros(size(Xbatch, 1), size(Xtrain, 1));

    for j = 1:size(Xbatch, 1)
        diff = Xtrain - Xbatch(j, :);
        distances(j, :) = sum(diff .^ 2, 2)';
    end

    [~, order] = sort(distances, 2, 'ascend');
    nearest = ytrain(order(:, 1:k));

    for j = 1:size(nearest, 1)
        counts = zeros(numel(classIds), 1);
        for c = 1:numel(classIds)
            counts(c) = sum(nearest(j, :) == classIds(c));
        end
        [~, best] = max(counts);
        predicted(first + j - 1) = classIds(best);
    end
end
end
