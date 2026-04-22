function figurePaths = make_speed_profile_plots(cfg)
%MAKE_SPEED_PROFILE_PLOTS Plot encoder speed patterns.

figurePaths = strings(0, 1);
fig = figure('Visible', 'off', 'Color', 'w', 'Position', [100 100 980 540]);
hold on;

for s = 1:numel(cfg.speedCodes)
    filename = sprintf('H-%s-3.mat', cfg.speedCodes{s});
    S = load(fullfile(cfg.dataFolder, filename));
    speed = S.Channel_2(:);
    stride = max(1, floor(numel(speed) / 6000));
    idx = 1:stride:numel(speed);
    t = (idx - 1) / cfg.fs;
    plot(t, speed(idx), 'LineWidth', 1.4);
end

grid on;
xlabel('Time (s)');
ylabel('Encoder speed signal');
title('Rotational speed patterns using healthy trial 3 files');
legend(cfg.speedNames, 'Location', 'best');

outPath = fullfile(cfg.figureFolder, 'speed_profiles_trial3.png');
exportgraphics(fig, outPath, 'Resolution', 180);
close(fig);
figurePaths(end+1, 1) = string(outPath);
end
