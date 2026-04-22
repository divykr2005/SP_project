function envelope_analysis(filepath, fs)

data = load(filepath);
vib = data.Channel_1;

analytic = hilbert(vib);
env = abs(analytic);

N = length(env);
f = (0:N-1)*(fs/N);
Y = abs(fft(env));

figure;
plot(f(1:N/2), Y(1:N/2));
xlabel('Frequency (Hz)');
ylabel('Amplitude');
title('Envelope Spectrum');
end