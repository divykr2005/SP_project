function [Xtrain, Ytrain, Xtest, Ytest] = extract_features(folder, fs, win_time, overlap)

files = dir(fullfile(folder,'*.mat'));

win = round(win_time*fs);
step = round(win*(1-overlap));

Xtrain = []; Ytrain = [];
Xtest = []; Ytest = [];

for k = 1:length(files)

    filename = files(k).name;
    data = load(fullfile(folder,filename));
    vib = data.Channel_1;
    speed = data.Channel_2;

    N = length(vib);

    for i = 1:step:(N-win)

        seg = vib(i:i+win-1);
        spd = mean(speed(i:i+win-1));

        % ---- Features ----
        rms_val = rms(seg);
        kurt = kurtosis(seg);
        skew = skewness(seg);
        crest = max(abs(seg))/rms_val;
        var_val = var(seg);
        rms_norm = rms_val / spd;

        Y = abs(fft(seg));
        spec_energy = sum(Y.^2)/length(Y);

        feat = [rms_val kurt skew crest var_val rms_norm spec_energy];

        % ---- Label ----
        if startsWith(filename,'H')
            label = 0;
        elseif startsWith(filename,'I')
            label = 1;
        else
            label = 2;
        end

        % ---- Split by Trial Number ----
        if endsWith(filename,'3.mat')
            Xtest = [Xtest; feat];
            Ytest = [Ytest; label];
        else
            Xtrain = [Xtrain; feat];
            Ytrain = [Ytrain; label];
        end

    end
end
end