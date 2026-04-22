function order_tracking(filepath, fs)

data = load(filepath);
vib = data.Channel_1;
speed = data.Channel_2;

t = (0:length(vib)-1)/fs;

speed_rad = 2*pi*speed;
theta = cumtrapz(t, speed_rad);

theta_uniform = linspace(theta(1), theta(end), length(theta));
vib_resampled = interp1(theta, vib, theta_uniform);

N = length(vib_resampled);
Y = abs(fft(vib_resampled));
order = (0:N-1)/N;

figure;
plot(order(1:N/2), Y(1:N/2));
xlabel('Order');
ylabel('Amplitude');
title('Order Spectrum');
end