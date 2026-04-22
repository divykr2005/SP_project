function plot_speed_patterns(folder, fs)

files = dir(fullfile(folder,'H-*-3.mat'));

figure; hold on;

for k = 1:length(files)

    data = load(fullfile(folder,files(k).name));
    speed = data.Channel_2;
    t = (0:length(speed)-1)/fs;
    plot(t, speed);
end

xlabel('Time (s)');
ylabel('Speed');
title('Speed Pattern Comparison (Trial 3)');
legend('Pattern 1','Pattern 2','Pattern 3','Pattern 4');
end