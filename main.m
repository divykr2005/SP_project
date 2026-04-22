clc;
clear;
close all;

% Parameters
A = 1;          % Amplitude of pulse
T = 1;          % Half duration of pulse
f = -5:0.001:5; % Frequency range

% Fourier Transform of rectangular pulse
% H(f) = 2*A*T*sinc(2*f*T)
H = 2*A*T * sinc(2*f*T);

% Plot
figure;
plot(f, H, 'LineWidth', 2);
grid on;
xlabel('Frequency (Hz)');
ylabel('H(f)');
title('Fourier Transform of Rectangular Pulse');