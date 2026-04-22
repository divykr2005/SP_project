function figurePaths = make_feature_summary_plots(cfg, featureTable, fileSummary)
%MAKE_FEATURE_SUMMARY_PLOTS Create feature comparison figures.

figurePaths = strings(0, 1);

selected = {'rms_value_mean', 'kurtosis_value_mean', 'crest_factor_mean'};
titles = {'RMS', 'Kurtosis', 'Crest factor'};

fig = figure('Visible', 'off', 'Color', 'w', 'Position', [100 100 980 520]);
tiledlayout(1, 3, 'Padding', 'compact', 'TileSpacing', 'compact');

for k = 1:numel(selected)
    values = zeros(numel(cfg.healthNames), 1);
    errors = zeros(numel(cfg.healthNames), 1);

    for h = 1:numel(cfg.healthNames)
        mask = fileSummary.health_index == h;
        x = fileSummary.(selected{k})(mask);
        values(h) = mean(x);
        errors(h) = std(x);
    end

    nexttile;
    bar(values);
    hold on;
    errorbar(1:numel(values), values, errors, '.', 'Color', 'k', 'LineWidth', 1.1);
    grid on;
    title(titles{k});
    xticks(1:numel(cfg.healthNames));
    xticklabels(cfg.healthNames);
    xtickangle(25);
    ylabel('File-level mean');
end

outPath = fullfile(cfg.figureFolder, 'feature_summary_by_health.png');
exportgraphics(fig, outPath, 'Resolution', 180);
close(fig);
figurePaths(end+1, 1) = string(outPath);

% A compact feature importance proxy: absolute standardized class separation.
X = table2array(featureTable(:, cfg.vibrationFeatureNames));
y = featureTable.health_index;
score = zeros(numel(cfg.vibrationFeatureNames), 1);
for j = 1:numel(cfg.vibrationFeatureNames)
    overallStd = std(X(:, j));
    if overallStd == 0
        continue;
    end
    classMeans = zeros(numel(cfg.healthNames), 1);
    for h = 1:numel(cfg.healthNames)
        classMeans(h) = mean(X(y == h, j));
    end
    score(j) = (max(classMeans) - min(classMeans)) / overallStd;
end

[scoreSorted, idx] = sort(score, 'descend');
fig = figure('Visible', 'off', 'Color', 'w', 'Position', [100 100 920 600]);
barh(scoreSorted);
set(gca, 'YDir', 'reverse');
yticks(1:numel(idx));
yticklabels(cfg.vibrationFeatureNames(idx));
xlabel('Standardized class-separation score');
title('Feature separation proxy for health classes');
grid on;

outPath = fullfile(cfg.figureFolder, 'feature_separation_scores.png');
exportgraphics(fig, outPath, 'Resolution', 180);
close(fig);
figurePaths(end+1, 1) = string(outPath);
end
