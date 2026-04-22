function predict_file(model, folder, filename, fs, win_time, overlap)

data = load(fullfile(folder,filename));
vib = data.Channel_1;
speed = data.Channel_2;

win = round(win_time*fs);
step = round(win*(1-overlap));
N = length(vib);

predictions = [];

for i = 1:step:(N-win)

    seg = vib(i:i+win-1);
    spd = mean(speed(i:i+win-1));

    rms_val = rms(seg);
    kurt = kurtosis(seg);
    skew = skewness(seg);
    crest = max(abs(seg))/rms_val;
    var_val = var(seg);
    rms_norm = rms_val / spd;

    Y = abs(fft(seg));
    spec_energy = sum(Y.^2)/length(Y);

    feat = [rms_val kurt skew crest var_val rms_norm spec_energy];

    pred = predict(model, feat);
    predictions = [predictions; pred];
end

final = mode(predictions);

disp("Final Prediction:");
if final==0
    disp("Healthy");
elseif final==1
    disp("Inner Race Fault");
else
    disp("Outer Race Fault");
end
end