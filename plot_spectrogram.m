function plot_spectrogram(filepath, fs)

data = load(filepath);
vib = data.Channel_1;

figure;
spectrogram(vib,2048,1024,2048,fs,'yaxis');
title('Spectrogram');
end