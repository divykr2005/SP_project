function info = parse_bearing_filename(filename, cfg)
%PARSE_BEARING_FILENAME Decode names such as H-A-1.mat.

[~, baseName, ext] = fileparts(filename);
parts = split(string(baseName), "-");

if numel(parts) ~= 3
    error('Unexpected bearing filename: %s', filename);
end

healthCode = char(parts(1));
speedCode = char(parts(2));
trial = str2double(parts(3));

healthIndex = find(strcmp(cfg.healthCodes, healthCode), 1);
speedIndex = find(strcmp(cfg.speedCodes, speedCode), 1);

if isempty(healthIndex) || isempty(speedIndex) || isnan(trial)
    error('Could not parse bearing filename: %s', filename);
end

info.file = string([baseName, ext]);
info.baseName = string(baseName);
info.healthCode = string(healthCode);
info.healthIndex = healthIndex;
info.healthName = string(cfg.healthNames{healthIndex});
info.speedCode = string(speedCode);
info.speedIndex = speedIndex;
info.speedName = string(cfg.speedNames{speedIndex});
info.trial = trial;
info.caseIndex = (healthIndex - 1) * numel(cfg.speedCodes) + speedIndex;
info.caseName = string(sprintf('%s-%s', healthCode, speedCode));
end
