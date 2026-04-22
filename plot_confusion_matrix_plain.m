function outPath = plot_confusion_matrix_plain(confusion, classNames, titleText, outPath)
%PLOT_CONFUSION_MATRIX_PLAIN Save a toolbox-free confusion matrix.

fig = figure('Visible', 'off', 'Color', 'w', 'Position', [100 100 760 620]);
imagesc(confusion);
axis equal tight;
colormap(parula);
colorbar;
title(titleText, 'Interpreter', 'none');
xlabel('Predicted class');
ylabel('True class');
xticks(1:numel(classNames));
yticks(1:numel(classNames));
xticklabels(classNames);
yticklabels(classNames);
xtickangle(35);

maxValue = max(confusion(:));
if maxValue == 0
    maxValue = 1;
end
for r = 1:size(confusion, 1)
    for c = 1:size(confusion, 2)
        if confusion(r, c) > 0.55 * maxValue
            textColor = 'w';
        else
            textColor = 'k';
        end
        text(c, r, sprintf('%d', confusion(r, c)), ...
            'HorizontalAlignment', 'center', ...
            'FontWeight', 'bold', ...
            'Color', textColor);
    end
end

exportgraphics(fig, outPath, 'Resolution', 180);
close(fig);
end
