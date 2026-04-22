function figurePaths = make_severity_plots(cfg, severity)
%MAKE_SEVERITY_PLOTS Plot relative severity scores.

figurePaths = strings(0, 1);
T = severity.fileTable;
[~, order] = sortrows([T.health_index, T.severity_score], [1 2]);
T = T(order, :);

colors = zeros(height(T), 3);
for i = 1:height(T)
    if T.health_index(i) == 1
        colors(i, :) = [0.20 0.55 0.35];
    elseif T.health_index(i) == 2
        colors(i, :) = [0.70 0.20 0.20];
    else
        colors(i, :) = [0.20 0.35 0.70];
    end
end

fig = figure('Visible', 'off', 'Color', 'w', 'Position', [100 100 1180 620]);
b = bar(T.severity_score, 'FaceColor', 'flat');
b.CData = colors;
hold on;
yline(severity.goodThreshold, '--', 'Good threshold', 'LineWidth', 1.1);
yline(severity.severeThreshold, '--', 'Severe threshold', 'LineWidth', 1.1);
grid on;
xlabel('File');
ylabel('Relative severity score');
title('Estimated file-level abnormality severity');
xticks(1:height(T));
xticklabels(T.file);
xtickangle(70);

outPath = fullfile(cfg.figureFolder, 'severity_score_by_file.png');
exportgraphics(fig, outPath, 'Resolution', 180);
close(fig);
figurePaths(end+1, 1) = string(outPath);
end
