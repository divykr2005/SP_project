function figurePaths = make_signal_diagnostic_plots(cfg)
%MAKE_SIGNAL_DIAGNOSTIC_PLOTS Waveform, spectrogram, envelope, and order figures.

figurePaths = strings(0, 1);

figurePaths(end+1, 1) = string(make_waveform_comparison(cfg));

for i = 1:numel(cfg.representativeFiles)
    filename = cfg.representativeFiles{i};
    info = parse_bearing_filename(filename, cfg);
    label = lower(char(info.baseName));

    figurePaths(end+1, 1) = string(make_manual_spectrogram(cfg, filename, ...
        fullfile(cfg.figureFolder, ['spectrogram_', label, '.png'])));

    figurePaths(end+1, 1) = string(make_envelope_spectrum(cfg, filename, ...
        fullfile(cfg.figureFolder, ['envelope_spectrum_', label, '.png'])));

    figurePaths(end+1, 1) = string(make_order_spectrum(cfg, filename, ...
        fullfile(cfg.figureFolder, ['order_spectrum_', label, '.png'])));
end
end

function outPath = make_waveform_comparison(cfg)
fig = figure('Visible', 'off', 'Color', 'w', 'Position', [100 100 980 640]);
tiledlayout(3, 1, 'Padding', 'compact', 'TileSpacing', 'compact');

secondsToPlot = 0.50;
samplesToPlot = round(secondsToPlot * cfg.fs);
stride = 20;

for i = 1:numel(cfg.representativeFiles)
    filename = cfg.representativeFiles{i};
    info = parse_bearing_filename(filename, cfg);
    S = load(fullfile(cfg.dataFolder, filename));
    vib = S.Channel_1(1:samplesToPlot);
    idx = 1:stride:numel(vib);
    t = (idx - 1) / cfg.fs;

    nexttile;
    plot(t, vib(idx), 'LineWidth', 0.9);
    grid on;
    xlabel('Time (s)');
    ylabel('Vibration');
    title(sprintf('%s: %s, %s', filename, info.healthName, info.speedName), 'Interpreter', 'none');
end

outPath = fullfile(cfg.figureFolder, 'waveform_comparison_ha_ia_oa.png');
exportgraphics(fig, outPath, 'Resolution', 180);
close(fig);
end

function outPath = make_manual_spectrogram(cfg, filename, outPath)
S = load(fullfile(cfg.dataFolder, filename));
x = S.Channel_1(:);

downsampleFactor = 10;
x = x(1:downsampleFactor:end);
fsPlot = cfg.fs / downsampleFactor;
x = x - mean(x);

windowLength = 2048;
hop = 512;
nfft = 4096;
window = hann_plain(windowLength);
starts = 1:hop:(numel(x) - windowLength + 1);
spec = zeros(nfft / 2 + 1, numel(starts));

for i = 1:numel(starts)
    idx = starts(i):(starts(i) + windowLength - 1);
    Y = abs(fft(x(idx) .* window, nfft));
    spec(:, i) = 20 * log10(Y(1:(nfft / 2 + 1)) + eps);
end

freq = (0:(nfft / 2)) * fsPlot / nfft;
time = (starts + windowLength / 2 - 1) / fsPlot;

fig = figure('Visible', 'off', 'Color', 'w', 'Position', [100 100 980 560]);
imagesc(time, freq, spec);
axis xy;
ylim([0 10000]);
colormap(turbo);
colorbar;
xlabel('Time (s)');
ylabel('Frequency (Hz)');
title(sprintf('Manual STFT spectrogram: %s', filename), 'Interpreter', 'none');
exportgraphics(fig, outPath, 'Resolution', 180);
close(fig);
end

function outPath = make_envelope_spectrum(cfg, filename, outPath)
S = load(fullfile(cfg.dataFolder, filename));
x = S.Channel_1(:);

downsampleFactor = 10;
x = x(1:downsampleFactor:end);
fsPlot = cfg.fs / downsampleFactor;
x = x - mean(x);

env = analytic_envelope_plain(x);
env = env - mean(env);
n = numel(env);
Y = abs(fft(env));
halfCount = floor(n / 2) + 1;
freq = (0:(halfCount - 1))' * fsPlot / n;

fig = figure('Visible', 'off', 'Color', 'w', 'Position', [100 100 980 520]);
plot(freq, Y(1:halfCount), 'LineWidth', 0.9);
grid on;
xlim([0 2000]);
xlabel('Frequency (Hz)');
ylabel('Envelope spectrum amplitude');
title(sprintf('Envelope spectrum: %s', filename), 'Interpreter', 'none');
exportgraphics(fig, outPath, 'Resolution', 180);
close(fig);
end

function outPath = make_order_spectrum(cfg, filename, outPath)
S = load(fullfile(cfg.dataFolder, filename));
x = S.Channel_1(:);
speed = S.Channel_2(:);

downsampleFactor = 20;
x = x(1:downsampleFactor:end);
speed = speed(1:downsampleFactor:end);
fsPlot = cfg.fs / downsampleFactor;
t = (0:(numel(x) - 1))' / fsPlot;

speedHz = infer_speed_hz(speed);
speedHz = max(speedHz, 1e-3);
thetaRad = cumtrapz(t, 2 * pi * speedHz);
totalRevolutions = max((thetaRad(end) - thetaRad(1)) / (2 * pi), eps);

thetaUniform = linspace(thetaRad(1), thetaRad(end), numel(thetaRad))';
xUniform = interp1(thetaRad, x, thetaUniform, 'linear', 'extrap');
xUniform = xUniform - mean(xUniform);

n = numel(xUniform);
window = hann_plain(n);
Y = abs(fft(xUniform .* window));
halfCount = floor(n / 2) + 1;
orderAxis = (0:(halfCount - 1))' / totalRevolutions;

fig = figure('Visible', 'off', 'Color', 'w', 'Position', [100 100 980 520]);
plot(orderAxis, Y(1:halfCount), 'LineWidth', 0.9);
grid on;
xlim([0 50]);
xlabel('Order (cycles / revolution)');
ylabel('Amplitude');
title(sprintf('Approximate order spectrum: %s', filename), 'Interpreter', 'none');
exportgraphics(fig, outPath, 'Resolution', 180);
close(fig);
end

function window = hann_plain(n)
window = 0.5 - 0.5 * cos(2 * pi * (0:(n - 1))' / max(n - 1, 1));
end

function env = analytic_envelope_plain(x)
n = numel(x);
X = fft(x);
h = zeros(n, 1);
if mod(n, 2) == 0
    h(1) = 1;
    h(n / 2 + 1) = 1;
    h(2:(n / 2)) = 2;
else
    h(1) = 1;
    h(2:((n + 1) / 2)) = 2;
end
env = abs(ifft(X .* h));
end

function speedHz = infer_speed_hz(speed)
speed = double(speed(:));
if median(abs(speed)) > 100
    speedHz = speed / 60;
else
    speedHz = speed;
end
end
